part of 'http_cache_client.dart';

extension _CacheClientUtils on CacheClient {
  bool _shouldSkip(String method, CacheOptions options) {
    final rqMethod = method.toUpperCase();
    var result = (rqMethod != _getMethod);
    result &= (!options.allowPostMethod || rqMethod != _postMethod);

    return result;
  }

  /// Gets cache store from given [options]
  /// or defaults to interceptor store.
  CacheStore _getCacheStore(CacheOptions options) {
    return options.store ?? _store;
  }

  String _getCacheKey(HttpBaseRequest request) {
    return request.options.keyBuilder(
      url: request.inner.url,
      headers: request.inner.headers,
    );
  }

  /// Gets cache options from given [request]
  /// or defaults to interceptor options.
  CacheOptions _getCacheOptions(CacheOptions? cacheOptions) {
    return cacheOptions ?? _options;
  }

  /// Reads cached response from cache store and transforms it to Response object.
  Future<http.Response?> _loadResponse(HttpBaseRequest request) async {
    final existing = await _loadCacheResponse(request);
    // Transform CacheResponse to Response object
    return existing?.toResponse(request);
  }

  /// Reads cached response from cache store.
  Future<CacheResponse?> _loadCacheResponse(HttpBaseRequest request) async {
    final cacheKey = _getCacheKey(request);
    final cacheStore = _getCacheStore(request.options);
    final response = await cacheStore.get(cacheKey);

    if (response != null) {
      // Purge entry if staled
      final maxStale = request.options.maxStale;
      if ((maxStale == null || maxStale == Duration.zero) &&
          response.isStaled()) {
        await cacheStore.delete(cacheKey);
        return null;
      }

      return response.readContent(request.options);
    }

    return null;
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

  /// Writes cached response to cache store if strategy allows it.
  Future<void> _saveResponse(
    http.Response response,
    HttpBaseRequest request,
  ) async {
    final strategy = await CacheStrategyFactory(
      request: request,
      response: HttpBaseResponse(response),
      cacheOptions: request.options,
    ).compute(
      cacheResponseBuilder: () => response.toCacheResponse(
        key: request.options.keyBuilder(
          url: request.inner.url,
          headers: request.inner.headers,
        ),
        options: request.options,
      ),
    );

    final cacheResp = strategy.cacheResponse;
    if (cacheResp != null) {
      // Store response to cache store
      await _getCacheStore(request.options).set(cacheResp);
    }
  }
}
