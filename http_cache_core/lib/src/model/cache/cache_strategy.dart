import '../model.dart';

/// Cache strategy result containing either a request
/// or a cached response but not both.
class CacheStrategy {
  final BaseRequest? request;
  final CacheResponse? cacheResponse;

  const CacheStrategy(this.request, this.cacheResponse)
      : assert(request != null && cacheResponse == null ||
            request == null && cacheResponse != null);
}

/// A factory class for creating cache strategies based on HTTP requests and responses.
class CacheStrategyFactory {
  /// The HTTP request to be processed.
  final BaseRequest request;

  /// The HTTP response received, if any.
  final BaseResponse? response;

  /// The cached response, if available.
  final CacheResponse? cacheResponse;

  /// Options that dictate caching behavior.
  final CacheOptions cacheOptions;

  static const allowedStatusCodes = [
    // OK
    200,
    // Non-Authoritative Information
    203,
    // Moved Permanently
    301,
    // No-Content
    304,
    // Found
    302,
    // Temporary Redirect
    307,
    // Not found
    404,
    // Bad method
    405,
    // Not implemented
    501,
  ];

  /// Constructor for the CacheStrategyFactory.
  ///
  /// - [request] represents the HTTP request that will be processed.
  /// - [cacheOptions] defines the caching behavior to be applied.
  /// - [response] represents the HTTP response received, if any.
  /// - [cacheResponse] represents the cached response, if available.
  CacheStrategyFactory({
    required this.request,
    required this.cacheOptions,
    this.response,
    this.cacheResponse,
  });

  /// Computes a cache strategy based on the current request and response.
  ///
  /// This method assumes that the request can use the network and returns
  /// a [CacheStrategy] based on the cache options and the state of the
  /// response and cache.
  ///
  /// [cacheResponseBuilder] is an optional function that can be used to
  /// build a cache response if one does not already exist.
  Future<CacheStrategy> compute({
    Future<CacheResponse> Function()? cacheResponseBuilder,
  }) async {
    final resp = response;
    var cache = cacheResponse;

    final rqCacheCtrl = CacheControl.fromString(
      request.headers[cacheControlHeader],
    );

    if (cacheResponseBuilder != null && resp != null && cache == null) {
      // No cached response...
      if (_isCacheable(rqCacheCtrl, resp)) {
        // build it!
        return CacheStrategy(null, await cacheResponseBuilder());
      }
    }

    if (_hasConditions(request, rqCacheCtrl)) {
      return CacheStrategy(request, null);
    }

    // Check if the cached response is stale and should be discarded.
    if (cache?.maxStale != null && (cache?.isStaled() ?? false)) {
      cache = null;
    }

    if (cache case final cache?) {
      // We have a cached response

      // If the cache policy is to force cache, return the cached response.
      if (cacheOptions.policy == CachePolicy.forceCache) {
        return CacheStrategy(null, cache);
      }

      // Check if the cached response is still fresh.
      if (!cache.isExpired(rqCacheCtrl)) {
        return CacheStrategy(null, cache);
      }

      // Prepare to validate the cached response with the server.
      if (cache.eTag case final eTag?) {
        request.setHeader(ifNoneMatchHeader, eTag);
      } else if (cache.lastModified case final lastModified?) {
        request.setHeader(ifModifiedSinceHeader, lastModified);
      } else if (cache.date case final date?) {
        request.setHeader(ifModifiedSinceHeader, HttpDate.format(date));
      }
    }

    // If no valid cached response is available, return a strategy to fetch from the network.
    return CacheStrategy(request, null);
  }

  /// Returns true if [response] can be stored to later serve another request.
  bool _isCacheable(CacheControl rqCacheCtrl, BaseResponse response) {
    if (cacheOptions.policy == CachePolicy.noCache) return false;

    if (_enforceResponseCachable()) return true;

    // Always go to network for uncacheable response codes
    final statusCode = response.statusCode;
    if (statusCode == null) return false;

    // Skip download
    if (response.isAttachment()) return false;

    final respCacheCtrl = CacheControl.fromHeader(
      response.headers[cacheControlHeader],
    );

    // revise no-store header with force policy options
    if (rqCacheCtrl.noStore || respCacheCtrl.noStore) {
      return false;
    }

    if (!allowedStatusCodes.contains(statusCode)) {
      if (statusCode == 302 || statusCode == 307) {
        // 302 & 307 can only be cached with the right response headers.
        // https://datatracker.ietf.org/doc/html/rfc7234#section-3
        if (response.headers[expiresHeader] == null &&
            respCacheCtrl.maxAge == -1 &&
            respCacheCtrl.privacy != null) {
          return false;
        }
      }
    }

    return _hasCacheDirectives(response, respCacheCtrl);
  }

  bool _enforceResponseCachable() {
    return switch (cacheOptions.policy) {
      CachePolicy.forceCache || CachePolicy.refreshForceCache => true,
      _ => false,
    };
  }

  bool _hasCacheDirectives(BaseResponse response, CacheControl respCacheCtrl) {
    var result = response.headers[etagHeader] != null;
    result |= response.headers[lastModifiedHeader] != null;
    result |= response.headers[expiresHeader] != null;
    result |= respCacheCtrl.maxAge > 0;

    return result;
  }

  /// Returns true if the request already contains conditions that save
  /// the server from sending a response that the client has locally.
  bool _hasConditions(BaseRequest request, CacheControl rqCacheCtrl) {
    final ifNoneMatch = request.headers[ifNoneMatchHeader];
    if (ifNoneMatch != null) {
      request.setHeader(ifModifiedSinceHeader, null);
    }

    return rqCacheCtrl.noCache ||
        request.headers[ifModifiedSinceHeader] != null;
  }
}
