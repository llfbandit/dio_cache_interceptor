import 'package:uuid/uuid.dart';

import '../../store/cache_store.dart';
import 'cache_cipher.dart';
import 'cache_policy.dart';
import 'cache_priority.dart';

/// Key builder to customize keys.
typedef CacheKeyBuilder = String Function({
  required Uri url,
  Map<String, String>? headers,
});

/// Options to apply to handle request and cache behaviour.
class CacheOptions {
  /// Handles behaviour to request backend.
  final CachePolicy policy;

  /// Allows to return previous cached response on given status codes.
  final List<int> hitCacheOnErrorCodes;

  /// Allows to return previous cached response on network failure (or offline).
  ///
  /// Socket exceptions like connect, send TO, receive TO, ..., will trigger the cache.
  final bool hitCacheOnNetworkFailure;

  /// Builds the unique key used for indexing a request in cache.
  /// Default to [CacheOptions.defaultCacheKeyBuilder]
  final CacheKeyBuilder keyBuilder;

  /// Overrides any HTTP directive to delete entry past this duration.
  ///
  /// This is manual operation! Don't be confused with Cache-Control#max-stale header.
  ///
  /// Giving this value to a later request will update the previously
  /// cached response with this directive.
  ///
  /// This allows to postpone the deletion or delete the entry with Duration.zero.
  final Duration? maxStale;

  /// The priority of a cached value.
  /// Ease the clean up if needed.
  final CachePriority priority;

  /// Store used for caching data.
  ///
  /// Required when setting interceptor.
  /// Optional when setting new options on dedicated requests.
  final CacheStore? store;

  /// Optional method to decrypt/encrypt cache content.
  final CacheCipher? cipher;

  /// allow POST method request to be cached.
  final bool allowPostMethod;

  // UUID helper to mark requests.
  static final _uuid = Uuid();

  const CacheOptions({
    this.policy = CachePolicy.request,
    this.hitCacheOnErrorCodes = const [],
    this.hitCacheOnNetworkFailure = false,
    this.keyBuilder = defaultCacheKeyBuilder,
    this.maxStale,
    this.priority = CachePriority.normal,
    this.cipher,
    this.allowPostMethod = false,
    required this.store,
  });

  /// Default cache key builder
  static String defaultCacheKeyBuilder({
    required Uri url,
    Map<String, String>? headers,
  }) {
    return _uuid.v5(Namespace.url.value, url.toString());
  }

  CacheOptions copyWith({
    CachePolicy? policy,
    List<int>? hitCacheOnErrorCodes,
    bool? hitCacheOnNetworkFailure,
    CacheKeyBuilder? keyBuilder,
    Duration? maxStale,
    CachePriority? priority,
    CacheStore? store,
    CacheCipher? cipher,
    bool? allowPostMethod,
  }) {
    return CacheOptions(
      policy: policy ?? this.policy,
      hitCacheOnErrorCodes: hitCacheOnErrorCodes ?? this.hitCacheOnErrorCodes,
      hitCacheOnNetworkFailure:
          hitCacheOnNetworkFailure ?? this.hitCacheOnNetworkFailure,
      keyBuilder: keyBuilder ?? this.keyBuilder,
      maxStale: maxStale ?? this.maxStale,
      priority: priority ?? this.priority,
      store: store ?? this.store,
      cipher: cipher ?? this.cipher,
      allowPostMethod: allowPostMethod ?? this.allowPostMethod,
    );
  }
}
