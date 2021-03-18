import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/model/cache_cipher.dart';
import 'package:uuid/uuid.dart';

import '../model/cache_priority.dart';
import '../store/cache_store.dart';

/// Key builder to customize your keys.
typedef CacheKeyBuilder = String Function(RequestOptions request);

/// Policy to handle request behaviour.
enum CachePolicy {
  /// Forces to return the cached value if available.
  /// Requests otherwise.
  /// Caches response regardless directives.
  ///
  /// In short, you'll save every successful GET requests.
  forceCache,

  /// Requests and skips cache save even if
  /// response has cache directives.
  noCache,

  /// Requests regardless cache availability.
  /// Caches if response has cache directives.
  refresh,

  /// Returns the cached value if available (and un-expired).
  ///
  /// Checks against origin server otherwise and updates cache freshness
  /// with returned headers.
  ///
  /// Requests otherwise and caches if response has directives.
  request,
}

/// Options to apply to handle request and cache behaviour.
class CacheOptions {
  /// Handles behaviour to request backend.
  final CachePolicy policy;

  /// Ability to return cache excepted on given status codes.
  /// Giving an empty list will hit cache on any status codes.
  ///
  /// Other errors, such as socket exceptions (connect, send TO, receive TO,
  /// ...),
  /// will trigger the cache.
  final List<int>? hitCacheOnErrorExcept;

  /// Builds the unique key used for indexing a request in cache.
  /// Default to [CacheOptions.defaultCacheKeyBuilder]
  final CacheKeyBuilder keyBuilder;

  /// Overrides any HTTP directive to delete entry past this duration.
  final Duration? maxStale;

  /// The priority of a cached value.
  /// Ease the clean up if needed.
  final CachePriority priority;

  /// Store used for caching data.
  ///
  /// Required when setting interceptor.
  /// Optional when setting new options on dedicated requests.
  final CacheStore? store;

  /// Optional method to decrypt/encrypt cache content
  final CacheCipher? cipher;

  // Key to retrieve options from request
  static const _extraKey = '@cache_options@';

  // UUID helper to mark requests
  static final _uuid = Uuid();

  const CacheOptions({
    this.policy = CachePolicy.request,
    this.hitCacheOnErrorExcept,
    this.keyBuilder = defaultCacheKeyBuilder,
    this.maxStale,
    this.priority = CachePriority.normal,
    this.cipher,
    required this.store,
  });

  static CacheOptions? fromExtra(RequestOptions request) {
    return request.extra[_extraKey];
  }

  static String defaultCacheKeyBuilder(RequestOptions request) {
    return _uuid.v5(Uuid.NAMESPACE_URL, request.uri.toString());
  }

  Map<String, dynamic> toExtra() {
    return {_extraKey: this};
  }

  Options toOptions() {
    return Options(extra: toExtra());
  }

  CacheOptions copyWith({
    CachePolicy? policy,
    List<int>? hitCacheOnErrorExcept,
    CacheKeyBuilder? keyBuilder,
    Duration? maxStale,
    CachePriority? priority,
    CacheStore? store,
    CacheCipher? cipher,
  }) {
    return CacheOptions(
      policy: policy ?? this.policy,
      hitCacheOnErrorExcept:
          hitCacheOnErrorExcept ?? this.hitCacheOnErrorExcept,
      keyBuilder: keyBuilder ?? this.keyBuilder,
      maxStale: maxStale ?? this.maxStale,
      priority: priority ?? this.priority,
      store: store ?? this.store,
      cipher: cipher ?? this.cipher,
    );
  }
}
