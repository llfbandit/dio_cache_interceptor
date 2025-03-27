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

class CacheStrategyFactory {
  final BaseRequest request;
  final BaseResponse? response;
  final CacheResponse? cacheResponse;
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

  CacheStrategyFactory({
    required this.request,
    required this.cacheOptions,
    this.response,
    this.cacheResponse,
  });

  /// Returns a strategy to use assuming the request can use the network.
  Future<CacheStrategy> compute({
    Future<CacheResponse> Function()? cacheResponseBuilder,
  }) async {
    final rqCacheCtrl = CacheControl.fromHeader(
      request.headerValuesAsList(cacheControlHeader),
    );

    final resp = response;
    if (cacheResponseBuilder != null && resp != null && cacheResponse == null) {
      // No cache response...
      if (_isCacheable(rqCacheCtrl, resp)) {
        // build it!
        return CacheStrategy(null, await cacheResponseBuilder());
      }
    }

    if (cacheResponse case final cacheResponse?) {
      // We have a cached response

      // Regardless cache response data, return it.
      if (cacheOptions.policy == CachePolicy.forceCache) {
        return CacheStrategy(null, cacheResponse);
      }

      // Check cached response freshness
      final respCtrl = cacheResponse.cacheControl;
      if (!respCtrl.noCache && !cacheResponse.isExpired(rqCacheCtrl)) {
        return CacheStrategy(null, cacheResponse);
      }

      // Find conditions to add to the request for validation.
      if (cacheResponse.eTag case final eTag?) {
        request.setHeader(ifNoneMatchHeader, eTag);
      }
      if (cacheResponse.lastModified case final lastModified?) {
        request.setHeader(ifModifiedSinceHeader, lastModified);
      } else if (cacheResponse.date case final date?) {
        request.setHeader(ifModifiedSinceHeader, HttpDate.format(date));
      }
    }

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
        if (response.headers[expiresHeader]?.first == null &&
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
}
