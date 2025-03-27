import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/model/dio_base_response.dart';
import 'package:dio_cache_interceptor/src/extension/cache_response_extension.dart';
import 'package:dio_cache_interceptor/src/extension/request_extension.dart';
import 'package:http_cache_core/http_cache_core.dart';

import 'model/dio_base_request.dart';
import 'extension/response_extension.dart';

part 'dio_cache_interceptor_cache_utils.dart';

/// Cache interceptor
class DioCacheInterceptor extends Interceptor {
  final CacheOptions _options;
  final CacheStore _store;

  DioCacheInterceptor({required CacheOptions options})
      : assert(options.store != null),
        _options = options,
        _store = options.store!;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add time when the request has been sent
    // for further expiry calculation.
    options.extra[extraRequestSentDateKey] = DateTime.now();

    final cacheOptions = _getCacheOptions(options);

    if (_shouldSkip(options, options: cacheOptions)) {
      handler.next(options);
      return;
    }

    // Early ends if policy does not require cache lookup.
    final policy = cacheOptions.policy;
    if (policy != CachePolicy.request && policy != CachePolicy.forceCache) {
      handler.next(options);
      return;
    }

    final strategy = await CacheStrategyFactory(
      request: DioBaseRequest(options),
      cacheResponse: await _loadCacheResponse(options),
      cacheOptions: cacheOptions,
    ).compute();

    var cacheResponse = strategy.cacheResponse;
    if (cacheResponse != null) {
      // Cache hit
      // Update cached response if needed
      cacheResponse = await _updateCacheResponse(cacheResponse, cacheOptions);

      handler.resolve(
        cacheResponse.toResponse(options, fromNetwork: false),
        true,
      );
    } else {
      // Requests with conditional request if available
      // or requests with given options
      if (strategy.request is DioBaseRequest) {
        handler.next((strategy.request as DioBaseRequest).request);
      } else {
        handler.next(options);
      }
    }
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final cacheOptions = _getCacheOptions(response.requestOptions);

    if (_shouldSkip(
      response.requestOptions,
      response: response,
      options: cacheOptions,
    )) {
      handler.next(response);
      return;
    }

    if (cacheOptions.policy == CachePolicy.noCache) {
      // Delete previous potential cached response
      await _getCacheStore(cacheOptions).delete(
        _getCacheKey(cacheOptions, response.requestOptions),
      );
    }

    // Is status 304 being set as valid status?
    if (response.statusCode == 304) {
      // Update cache response with response header values
      final cacheResponse = await _loadResponse(response.requestOptions);
      if (cacheResponse != null) {
        response = cacheResponse..updateCacheHeaders(response);
      }
    }

    await _saveResponse(
      response,
      cacheOptions,
      statusCode: response.statusCode,
    );

    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final cacheOptions = _getCacheOptions(err.requestOptions);

    if (_shouldSkip(err.requestOptions, options: cacheOptions, error: err)) {
      handler.next(err);
      return;
    }

    if (isCacheCheckAllowed(err.response?.statusCode, cacheOptions)) {
      // Retrieve response from cache
      final cacheResponse = await _loadResponse(err.requestOptions);

      if (err.response != null && cacheResponse != null) {
        // Update cache response with response header values
        await _saveResponse(
          cacheResponse..updateCacheHeaders(err.response!),
          cacheOptions,
          statusCode: err.response?.statusCode,
        );
      }

      // Resolve with found cached response
      if (cacheResponse != null) {
        handler.resolve(cacheResponse);
        return;
      }
    }

    handler.next(err);
  }
}
