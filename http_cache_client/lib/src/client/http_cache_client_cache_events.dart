part of 'http_cache_client.dart';

const String _getMethod = 'GET';
const String _postMethod = 'POST';

extension _CacheClientEvents on CacheClient {
  Future<http.Response> _onRequest(
    String method,
    Uri url,
    Map<String, String>? headers,
    CacheOptions options, [
    Object? body,
    Encoding? encoding,
  ]) async {
    final request =
        _prepareRequest(options, method, url, headers, body, encoding);

    if (!_shouldSkip(method, options)) {
      // Early ends if policy does not require cache lookup.
      if (options.policy != CachePolicy.request &&
          options.policy != CachePolicy.forceCache) {
        return _sendUnstreamedRequest(request);
      }

      final strategy = await CacheStrategyFactory(
        request: request,
        cacheResponse: await _loadCacheResponse(
          request,
          readHeaders: true,
          readBody: false,
        ),
        cacheOptions: options,
      ).compute();

      var cacheResponse = strategy.cacheResponse;
      if (cacheResponse != null) {
        // Cache hit

        // Finish reading content from cached response
        cacheResponse = await cacheResponse.readContent(
          options,
          readHeaders: false,
          readBody: true,
        );

        // Update cached response if needed
        cacheResponse = await _updateCacheResponse(cacheResponse, options);

        return cacheResponse.toResponse(request);
      }

      // Requests with conditional request if available
      // or requests with given options
      if (strategy.request is HttpBaseRequest) {
        return _sendUnstreamedRequest(strategy.request as HttpBaseRequest);
      }
    }

    return _sendUnstreamedRequest(request);
  }

  Future<http.Response> _onResponse(
    http.Response response,
    HttpBaseRequest request,
  ) async {
    if (_shouldSkip(request.inner.method, request.options)) {
      return response;
    }

    if (request.options.policy == CachePolicy.noCache) {
      // Delete previous potential cached response
      await _getCacheStore(request.options).delete(_getCacheKey(request));
    }

    if (isCacheCheckAllowed(response.statusCode, request.options)) {
      // Update cache response with response header values
      final cacheResponse = await _loadResponse(request);
      if (cacheResponse != null) {
        response = cacheResponse..updateCacheHeaders(response);
      }
    }

    await _saveResponse(response, request);

    return response;
  }

  Future<http.Response> _onError(
    http.ClientException exception,
    HttpBaseRequest request,
  ) async {
    if (_shouldSkip(request.inner.method, request.options)) {
      throw exception;
    }

    if (isCacheCheckAllowed(null, request.options)) {
      final cacheResponse = await _loadResponse(request);
      if (cacheResponse != null) {
        return cacheResponse;
      }
    }

    throw exception;
  }
}
