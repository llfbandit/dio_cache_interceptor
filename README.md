Dio HTTP cache interceptor with multiple stores respecting HTTP directives.

HTTP directives (currently):
- ETag
- Last-Modified

## Options
`CacheOptions` is available widely on interceptor and on requests to take precedence over your global settings.

See [documentation](https://pub.dev/documentation/dio_cache_interceptor/latest/) for all properties.

## Usage

```dart
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

// The store used.
final cacheStore = DbCacheStore();

// Add cache interceptor and global options
final dio = Dio()
  ..interceptors.add(DioCacheInterceptor(
    options: const CacheOptions(
      store: cacheStore, // Required. The store used.
      policy: CachePolicy.requestFirst, // Default. Request firt and cache response.
      hitCacheOnErrorExcept: [401], // Returns a cached response on error if available expected for status 401
      priority: CachePriority.normal, // Default. Priority to separate critical cache entries
      maxStale: const Duration(days: 7), // Optional. Override any HTTP directive to delete entry past this duration.
    )
  )
);

// Apply specific options for the current request
final response = await dio.get('http://www.foo.com',
  options: Options(
    extra: CacheOptions(
      policy: CachePolicy.cacheFirst,
      store: cacheStore,
    ).toExtra(),
  ),
);
```

## Options
### Cache options
```dart
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
}
```

### Cache policy
```dart
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
```

## Stores
- DbCacheStore: Cache with DB (sqflite).
- FileCacheStore: Cache with file system.

```dart
  /// Retrieve cached response from store
  Future<CacheResponse> get(String key);

  /// Push response in store
  Future<void> set(CacheResponse response);

  /// Remove the given key from store.
  /// [stalledOnly] flag will remove it only if the key is expired
  /// (from maxStale).
  Future<void> delete(String key, {bool stalledOnly = false});

  /// Remove all keys from store.
  /// [priorityOrBelow] flag will remove keys only for the priority or below.
  /// [stalledOnly] flag will remove keys only if expired
  /// (from maxStale).
  ///
  /// By default, all keys will be removed.
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool stalledOnly = false,
  });
```

## Roadmap
- Memory store
- Backup store
- Cache-Control (well... a subset)

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/llfbandit/dio_cache_interceptor/issues

## License

[license](https://github.com/llfbandit/dio_cache_interceptor/blob/master/LICENSE).