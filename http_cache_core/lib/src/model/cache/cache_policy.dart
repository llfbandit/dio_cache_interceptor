/// Policy to handle request behaviour.
enum CachePolicy {
  /// Same as [CachePolicy.request] when origin server has no cache config.
  ///
  /// In short, you'll save every successful GET requests.
  forceCache,

  /// Same as [CachePolicy.refresh] when origin server has no cache config.
  refreshForceCache,

  /// Requests and skips cache save even if
  /// response has cache directives.
  noCache,

  /// Requests regardless cache availability.
  /// Caches if response has cache directives.
  refresh,

  /// Returns the cached value if available (and un-expired).
  ///
  /// Checks against origin server otherwise and updates cache freshness
  /// with returned headers when validation is needed.
  ///
  /// Requests otherwise and caches if response has directives.
  request,
}
