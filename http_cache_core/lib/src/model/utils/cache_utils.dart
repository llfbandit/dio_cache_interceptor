import '../cache/cache_options.dart';

/// Checks if we can try to resolve cached response
/// against given [statusCode] and [cacheOptions].
bool isCacheCheckAllowed(int? statusCode, CacheOptions cacheOptions) {
  // Determine if we can return cached response
  if (statusCode == 304) {
    return true;
  } else if (statusCode == null && cacheOptions.hitCacheOnNetworkFailure) {
    // Offline or any other connection error
    return true;
  } else if (cacheOptions.hitCacheOnErrorCodes.contains(statusCode)) {
    // Status code is allowed to try cache look up.
    return true;
  }

  return false;
}
