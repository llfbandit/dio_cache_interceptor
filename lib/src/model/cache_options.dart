import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../model/cache_priority.dart';
import '../store/cache_store.dart';

/// Key builder to customize your keys.
typedef CacheKeyBuilder = String Function(RequestOptions request);

/// Encrypt content method.
typedef Encrypt = Future<List<int>> Function(List<int> bytes);

/// Decrypt content method.
typedef Decrypt = Future<List<int>> Function(List<int> bytes);

/// Policy to handle request behaviour.
enum CachePolicy {
  /// Forces to return the cached value if available.
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
  cacheStoreNo,

  /// Forces to request, even if a valid
  /// cache is available.
  refresh,

  /// Requests and caches if
  /// response has cache directives.
  requestFirst,
}

/// Options to apply to handle request and cache behaviour.
class CacheOptions {
  /// Handle behaviour to request backend.
  final CachePolicy policy;

  /// Ability to return cache excepted on given status codes.
  /// Giving an empty list will hit cache on any error.
  final List<int> hitCacheOnErrorExcept;

  /// Builds the unique key used for indexing a request in cache.
  /// Default to [CacheOptions.defaultCacheKeyBuilder]
  final CacheKeyBuilder keyBuilder;

  /// Override any HTTP directive to delete entry past this duration.
  final Duration maxStale;

  /// The priority of a cached value.
  /// Ease the clean up if needed.
  final CachePriority priority;

  /// The store used for caching data.
  final CacheStore store;

  /// Optional method to decrypt cache content
  final Decrypt decrypt;

  /// Optional method to encrypt cache content
  final Encrypt encrypt;

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
    this.decrypt,
    this.encrypt,
    @required this.store,
  })  : assert(policy != null),
        assert(keyBuilder != null),
        assert(priority != null),
        assert(store != null),
        assert((decrypt == null && encrypt == null) ||
            (decrypt != null && encrypt != null));

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
