import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../model/cache_priority.dart';
import '../store/cache_store.dart';
import 'cipher.dart';

/// Key builder to customize your keys.
typedef CacheKeyBuilder = String Function(RequestOptions request);

/// Policy to handle request behaviour.
enum CachePolicy {
  /// Returns the cached value if available.
  /// Requests otherwise.
  cacheFirst,

  /// Forces to return the cached value if available.
  /// Requests otherwise.
  /// Caches response regardless directives.
  ///
  /// In short, you'll save every successful GET requests.
  cacheStoreForce,

  /// Requests and skips cache save even if
  /// response has cache directives.
  ///
  /// Note: previously stored response stays untouched.
  cacheStoreNo,

  /// Forces to request, even if a valid
  /// cache is available and caches if
  /// response has cache directives.
  refresh,

  /// Requests and caches if response has directives.
  requestFirst,
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

  /// Optional store used for caching data.
  final CacheStore? store;

  /// Optional encryption/decryption for cache content
  final Cipher? cipher;

  // Key to retrieve options from request
  static const _extraKey = '@cache_options@';

  // UUID helper to mark requests
  static final _uuid = Uuid();

  const CacheOptions({
    this.policy = CachePolicy.requestFirst,
    this.hitCacheOnErrorExcept,
    this.keyBuilder = defaultCacheKeyBuilder,
    this.maxStale,
    this.priority = CachePriority.normal,
    this.cipher,
    this.store,
  });

  factory CacheOptions.fromExtra(RequestOptions request) {
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
}
