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
    307
  ];

  CacheStrategyFactory({
    required this.request,
    required this.cacheOptions,
    this.response,
    this.cacheResponse,
  });

  /// Returns a strategy to use assuming the request can use the network.
  Future<CacheStrategy> compute() async {
    final requestCaching = CacheControl.fromHeader(
      request.headerValuesAsList(cacheControlHeader),
    );

    // Check if we need to return early
    if (!_isCacheable(requestCaching, response)) {
      return CacheStrategy(request, null);
    }

    // Build cache reponse
    final receivedResponse = response;
    if (receivedResponse != null &&
        cacheResponse == null &&
        _hasCacheDirectives(receivedResponse)) {
      cacheResponse = await CacheResponse.fromResponse(
        key: cacheOptions.keyBuilder(request),
        options: cacheOptions,
        response: receivedResponse,
      );

      return CacheStrategy(null, cacheResponse);
    }

    // We have a cached reponse
    final cache = cacheResponse;
    if (cache != null) {
      // Regardless cache response data, return it.
      if (cacheOptions.policy == CachePolicy.forceCache) {
        return CacheStrategy(null, cache);
      }

      // Check cached response freshness
      final responseCaching = cache.cacheControl;

      if (!responseCaching.noCache &&
          !cache.isExpired(requestCaching: requestCaching)) {
        return CacheStrategy(null, cache);
      }

      // Find conditions to add to the request for validation.
      if (cache.eTag != null) {
        request.headers[ifNoneMatchHeader] = cache.eTag;
      }
      if (cache.lastModified != null) {
        request.headers[ifModifiedSinceHeader] = cache.lastModified;
      } else if (cache.date != null) {
        request.headers[ifModifiedSinceHeader] = HttpDate.format(cache.date!);
      }
    }

    return CacheStrategy(request, null);
  }

  /// Returns true if [response] can be stored to later serve another request.
  bool _isCacheable(CacheControl requestCaching, Response? response) {
    final policy = cacheOptions.policy;
    if (policy == CachePolicy.noCache) {
      return false;
    }

    if (response != null) {
      // Skip download
      if (response.isAttachment()) return false;

      final responseCaching = CacheControl.fromHeader(
        response.headers[cacheControlHeader],
      );
      // revise no-store header with force policy options
      if (responseCaching.noStore && !_enforceResponseCachable()) return false;

      // Always go to network for uncacheable
      // response codes (RFC 7231 section 6.1)
      final statusCode = response.statusCode;
      if (statusCode == null) return false;
      if (!allowedStatusCodes.contains(statusCode)) {
        if (statusCode != 302 && statusCode != 307) {
          return false;
        }

        // 302 & 307 can only be cached with the right response headers.
        // https://datatracker.ietf.org/doc/html/rfc7234#section-3
        if (response.headers[expiresHeader]?.first == null &&
            responseCaching.maxAge == -1 &&
            responseCaching.privacy != null) {
          return false;
        }
      }
    }

    // revise no-store header with force policy options
    if (requestCaching.noStore && !_enforceResponseCachable()) return false;

    return true;
  }

  bool _hasCacheDirectives(Response response) {
    if (_enforceResponseCachable()) {
      return true;
    }

    var result = response.headers[etagHeader] != null;
    result |= response.headers[lastModifiedHeader] != null;

    return result;
  }

  bool _enforceResponseCachable() {
    final policy = cacheOptions.policy;

    return policy == CachePolicy.forceCache ||
        policy == CachePolicy.refreshForceCache;
  }
}
