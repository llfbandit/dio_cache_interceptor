import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor/src/util/contants.dart';
import 'package:dio_cache_interceptor/src/util/http_date.dart';
import 'package:dio_cache_interceptor/src/util/request_extension.dart';
import 'package:dio_cache_interceptor/src/util/response_extension.dart';

class CacheStrategy {
  final RequestOptions? request;
  final CacheResponse? cacheResponse;

  const CacheStrategy(this.request, this.cacheResponse);
}

class CacheStrategyFactory {
  final RequestOptions request;
  final Response? response;
  CacheResponse? cacheResponse;
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
  Future<CacheStrategy> compute() async {
    final rqCacheCtrl = CacheControl.fromHeader(
      request.headerValuesAsList(cacheControlHeader),
    );

    // Build cache reponse
    final resp = response;
    if (resp != null && cacheResponse == null) {
      if (_enforceResponseCachable() || _isCacheable(rqCacheCtrl, resp)) {
        cacheResponse = await CacheResponse.fromResponse(
          key: cacheOptions.keyBuilder(request),
          options: cacheOptions,
          response: resp,
        );

        return CacheStrategy(null, cacheResponse);
      }
    }

    final cache = cacheResponse;
    if (cache != null) {
      // We have a cached reponse

      // Regardless cache response data, return it.
      if (cacheOptions.policy == CachePolicy.forceCache) {
        return CacheStrategy(null, cache);
      }

      // Check cached response freshness
      final respCtrl = cache.cacheControl;
      if (!respCtrl.noCache && !cache.isExpired(rqCacheCtrl)) {
        return CacheStrategy(null, cache);
      }

      // Find conditions to add to the request for validation.
      if (cache.eTag != null) {
        request.headers[ifNoneMatchHeader] = cache.eTag;
      } else if (cache.lastModified != null) {
        request.headers[ifModifiedSinceHeader] = cache.lastModified;
      } else if (cache.date != null) {
        request.headers[ifModifiedSinceHeader] = HttpDate.format(cache.date!);
      }
    }

    return CacheStrategy(request, null);
  }

  /// Returns true if [response] can be stored to later serve another request.
  bool _isCacheable(CacheControl rqCacheCtrl, Response response) {
    if (cacheOptions.policy == CachePolicy.noCache) return false;

    // Always go to network for uncacheable response codes
    final statusCode = response.statusCode;
    if (statusCode == null) return false;

    // Skip download
    if (response.isAttachment()) return false;

    final respCacheCtrl = CacheControl.fromHeader(
      response.headers[cacheControlHeader],
    );

    // revise no-store header with force policy options
    if ((rqCacheCtrl.noStore || respCacheCtrl.noStore) &&
        !_enforceResponseCachable()) return false;

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
    final policy = cacheOptions.policy;

    return policy == CachePolicy.forceCache ||
        policy == CachePolicy.refreshForceCache;
  }

  bool _hasCacheDirectives(Response response, CacheControl respCacheCtrl) {
    if (_enforceResponseCachable()) {
      return true;
    }

    var result = response.headers[etagHeader] != null;
    result |= response.headers[lastModifiedHeader] != null;
    result |= response.headers[expiresHeader] != null;
    result |= respCacheCtrl.maxAge > 0;

    return result;
  }
}
