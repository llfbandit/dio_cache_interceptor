import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/model/cache_control.dart';
import 'package:dio_cache_interceptor/src/util/http_date.dart';

import './model/cache_response.dart';
import './store/cache_store.dart';
import 'model/cache_options.dart';
import 'util/content_serialization.dart';

/// Cache interceptor
class DioCacheInterceptor extends Interceptor {
  static const String _getMethodName = 'GET';

  static const _cacheControlHeader = 'cache-control';
  static const _dateHeader = 'date';
  static const _etagHeader = 'etag';
  static const _expiresHeader = 'expires';
  static const _ifModifiedSinceHeader = 'if-modified-since';
  static const _ifNoneMatchHeader = 'if-none-match';
  static const _lastModifiedHeader = 'last-modified';

  final CacheOptions _options;
  final CacheStore _store;

  DioCacheInterceptor({required CacheOptions options})
      : assert(options.store != null),
        _options = options,
        _store = options.store!;

  @override
  void onRequest(
    RequestOptions request,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldSkipRequest(request)) {
      handler.next(request);
      return;
    }

    final options = _getCacheOptions(request);

    if (options.policy != CachePolicy.refresh) {
      final cacheResp = await _getCacheResponse(request);
      if (cacheResp != null) {
        if (_shouldReturnCache(options, cacheResp)) {
          handler.resolve(cacheResp.toResponse(request, fromNetwork: false));
          return;
        }

        // Update request with cache directives
        _addCacheDirectives(request, cacheResp);
      }
    }

    handler.next(request);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (_shouldSkipRequest(response.requestOptions)) {
      handler.next(response);
      return;
    }

    // Don't cache response
    if (response.statusCode != 200) {
      handler.next(response);
      return;
    }

    final cacheOptions = _getCacheOptions(response.requestOptions);
    final policy = cacheOptions.policy;

    if (policy == CachePolicy.cacheStoreNo) {
      handler.next(response);
      return;
    }

    // Cache response into store
    if (_hasCacheDirectives(response, policy: policy)) {
      final cacheResp = await _buildCacheResponse(
        cacheOptions.keyBuilder(response.requestOptions),
        cacheOptions,
        response,
      );

      await _getCacheStore(cacheOptions).set(cacheResp);

      response.extra.putIfAbsent(CacheResponse.cacheKey, () => cacheResp.key);
      response.extra.putIfAbsent(CacheResponse.fromNetwork, () => true);
    }

    handler.next(response);
  }

  @override
  void onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldSkipRequest(err.requestOptions, error: err)) {
      handler.next(err);
      return;
    }

    var returnResponse = false;

    // Retrieve response from cache
    final errResponse = err.response;
    if (errResponse != null) {
      if (errResponse.statusCode == 304) {
        returnResponse = true;
      } else {
        final cacheOpts = _getCacheOptions(err.requestOptions);

        // Check if we can return cache on error
        final hcoeExcept = cacheOpts.hitCacheOnErrorExcept;
        if (hcoeExcept == null) {
          returnResponse = false;
        } else if (err.type == DioErrorType.response &&
            hcoeExcept.contains(errResponse.statusCode)) {
          returnResponse = false;
        } else {
          returnResponse = true;
        }
      }
    }

    if (returnResponse) {
      final response = await _getResponse(
        err.requestOptions,
        fromNetwork: true,
      );
      handler.resolve(response!);
      return;
    } else {
      handler.next(err);
    }
  }

  void _addCacheDirectives(RequestOptions request, CacheResponse response) {
    if (response.eTag != null) {
      request.headers[_ifNoneMatchHeader] = response.eTag;
    }

    if (response.lastModified != null) {
      request.headers[_ifModifiedSinceHeader] = response.lastModified;
    }
  }

  bool _hasCacheDirectives(Response response, {CachePolicy? policy}) {
    if (policy == CachePolicy.cacheStoreForce) {
      return true;
    }

    var result = response.headers[_etagHeader] != null;
    result |= response.headers[_lastModifiedHeader] != null;

    final cacheControl = CacheControl.fromHeader(
      response.headers[_cacheControlHeader],
    );

    if (cacheControl != null) {
      result &= !(cacheControl.noStore ?? false);
    }

    return result;
  }

  bool _shouldReturnCache(CacheOptions options, CacheResponse cacheResp) {
    // Forced cache response
    if (options.policy == CachePolicy.cacheStoreForce) {
      return true;
    }

    return !cacheResp.isExpired();
  }

  CacheOptions _getCacheOptions(RequestOptions request) {
    return CacheOptions.fromExtra(request) ?? _options;
  }

  CacheStore _getCacheStore(CacheOptions options) {
    return options.store ?? _store;
  }

  bool _shouldSkipRequest(RequestOptions? request, {DioError? error}) {
    var result = error?.type == DioErrorType.cancel;
    result |= (request?.method.toUpperCase() != _getMethodName);
    return result;
  }

  Future<CacheResponse> _buildCacheResponse(
    String key,
    CacheOptions options,
    Response response,
  ) async {
    final content = await _encryptContent(
      options,
      await serializeContent(
        response.requestOptions.responseType,
        response.data,
      ),
    );

    final headers = await _encryptContent(
      options,
      utf8.encode(jsonEncode(response.headers.map)),
    );

    final dateStr = response.headers[_dateHeader]?.first;
    final date =
        (dateStr != null) ? HttpDate.parse(dateStr) : DateTime.now().toUtc();

    final expiresDateStr = response.headers[_expiresHeader]?.first;
    DateTime? httpExpiresDate;
    if (expiresDateStr != null) {
      try {
        httpExpiresDate = HttpDate.parse(expiresDateStr);
      } catch (_) {
        // Invalid date format, meaning something already expired
        httpExpiresDate = DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true);
      }
    }

    final checkedMaxStale = options.maxStale;

    return CacheResponse(
      cacheControl: CacheControl.fromHeader(
        response.headers[_cacheControlHeader],
      ),
      content: content,
      date: date,
      eTag: response.headers[_etagHeader]?.first,
      expires: httpExpiresDate,
      headers: headers,
      key: key,
      lastModified: response.headers[_lastModifiedHeader]?.first,
      maxStale: checkedMaxStale != null
          ? DateTime.now().toUtc().add(checkedMaxStale)
          : null,
      priority: options.priority,
      responseDate: DateTime.now().toUtc(),
      url: response.requestOptions.uri.toString(),
    );
  }

  Future<CacheResponse?> _getCacheResponse(RequestOptions request) async {
    final cacheOpts = _getCacheOptions(request);
    final cacheKey = cacheOpts.keyBuilder(request);
    final result = await _getCacheStore(cacheOpts).get(cacheKey);

    if (result != null) {
      result.content = await _decryptContent(cacheOpts, result.content);
      result.headers = await _decryptContent(cacheOpts, result.headers);
    }

    return result;
  }

  Future<Response?> _getResponse(
    RequestOptions? request, {
    required bool fromNetwork,
  }) async {
    if (request == null) return null;
    final existing = await _getCacheResponse(request);
    return existing?.toResponse(request, fromNetwork: fromNetwork);
  }

  Future<List<int>?> _decryptContent(CacheOptions options, List<int>? bytes) {
    final checkedCipher = options.cipher;
    if (bytes != null && checkedCipher != null) {
      return checkedCipher.decrypt(bytes);
    }

    return Future.value(bytes);
  }

  Future<List<int>?> _encryptContent(CacheOptions options, List<int>? bytes) {
    final checkedCipher = options.cipher;
    if (bytes != null && checkedCipher != null) {
      return checkedCipher.encrypt(bytes);
    }
    return Future.value(bytes);
  }
}
