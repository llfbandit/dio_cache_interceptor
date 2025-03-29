part of 'dio_cache_interceptor.dart';

const String _getMethod = 'GET';
const String _postMethod = 'POST';

extension _DioCacheInterceptorUtils on DioCacheInterceptor {
  /// Gets cache options from given [request]
  /// or defaults to interceptor options.
  CacheOptions _getCacheOptions(RequestOptions request) {
    return request.getCacheOptions() ?? _options;
  }

  /// Gets cache store from given [options]
  /// or defaults to interceptor store.
  CacheStore _getCacheStore(CacheOptions options) {
    return options.store ?? _store;
  }

  /// Check if the callback should not be proceed against HTTP method
  /// or cancel error type.
  bool _shouldSkip(
    RequestOptions? request, {
    required CacheOptions options,
    Response? response,
    DioException? error,
  }) {
    if (error?.type == DioExceptionType.cancel) {
      return true;
    }

    if (response?.extra[extraCacheKey] != null) {
      return true;
    }

    final rqMethod = request?.method.toUpperCase();
    var result = (rqMethod != _getMethod);
    result &= (!options.allowPostMethod || rqMethod != _postMethod);

    return result;
  }

  /// Reads cached response from cache store.
  Future<CacheResponse?> _loadCacheResponse(
    RequestOptions request, {
    required bool readHeaders,
    required bool readBody,
  }) async {
    final options = _getCacheOptions(request);
    final cacheKey = _getCacheKey(options, request);
    final cacheStore = _getCacheStore(options);
    final response = await cacheStore.get(cacheKey);

    return response?.readContent(
      options,
      readHeaders: readHeaders,
      readBody: readBody,
    );
  }

  /// Reads cached response from cache store and transforms it to Response object.
  Future<Response?> _loadResponse(RequestOptions request) async {
    final existing = await _loadCacheResponse(
      request,
      readHeaders: true,
      readBody: true,
    );

    // Transform CacheResponse to Response object
    return existing?.toResponse(request);
  }

  /// Writes cached response to cache store if strategy allows it.
  Future<void> _saveResponse(
    Response response,
    CacheOptions cacheOptions, {
    int? statusCode,
  }) async {
    final strategy = await CacheStrategyFactory(
      request: DioBaseRequest(response.requestOptions),
      response: DioBaseResponse(response),
      cacheOptions: cacheOptions,
    ).compute(
      cacheResponseBuilder: () => response.toCacheResponse(
        key: _getCacheKey(cacheOptions, response.requestOptions),
        options: cacheOptions,
      ),
    );

    final cacheResp = strategy.cacheResponse;
    if (cacheResp != null) {
      // Store response to cache store
      await _getCacheStore(cacheOptions).set(cacheResp);

      // Update extra fields with cache info
      response.extra[extraCacheKey] = cacheResp.key;
      response.extra[extraFromNetworkKey] =
          CacheStrategyFactory.allowedStatusCodes.contains(statusCode);
    }
  }

  /// Updates cached response if input has maxStale
  /// This allows to push off deletion of the entry.
  Future<CacheResponse> _updateCacheResponse(
    CacheResponse cacheResponse,
    CacheOptions cacheOptions,
  ) async {
    // Add or update maxStale
    final maxStaleUpdate = cacheOptions.maxStale;
    if (maxStaleUpdate != null) {
      cacheResponse = cacheResponse.copyWith(
        maxStale: DateTime.now().toUtc().add(maxStaleUpdate),
      );

      // Store response to cache store
      await _getCacheStore(cacheOptions).set(
        await cacheResponse.writeContent(cacheOptions),
      );
    }

    return cacheResponse;
  }

  String _getCacheKey(CacheOptions options, RequestOptions request) {
    return options.keyBuilder(
      url: request.uri,
      headers: request.getFlattenHeaders(),
    );
  }
}
