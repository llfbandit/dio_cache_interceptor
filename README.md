Dio HTTP cache interceptor with multiple stores respecting HTTP directives (or not).

HTTP directives (currently):
- ETag
- Last-Modified

## Options
`CacheOptions` is available widely on interceptor and on requests to take precedence over your global settings.

See [documentation](https://pub.dev/documentation/dio_cache_interceptor/latest/dio_cache_interceptor/dio_cache_interceptor-library.html) for all properties.

## Stores
- DbCacheStore: Cache with DB (sqflite).
- FileCacheStore: Cache with file system.
- MemCacheStore: Volatile cache with LRU strategy.

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
      policy: CachePolicy.requestFirst, // Default. Requests firt and caches response.
      hitCacheOnErrorExcept: [401, 403], // Returns a cached response on error if available but for statuses 401 & 403.
      priority: CachePriority.normal, // Default. Priority to separate cache entries.
      maxStale: const Duration(days: 7), // Optional. Override any HTTP directive to delete entry past this duration.
    )
  )
);

// Request with global options
var response = await dio.get('http://www.foo.com');

// Apply specific options for the current request
response = await dio.get('http://www.foo.com',
  options: Options(
    extra: CacheOptions(
      policy: CachePolicy.refresh,
      store: cacheStore,
    ).toExtra(),
  ),
);
```

## Options
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

## Roadmap
- Backup store (primary, secondary)
- Cache-Control (a subset)

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/llfbandit/dio_cache_interceptor/issues

## License

[License](https://github.com/llfbandit/dio_cache_interceptor/blob/master/LICENSE).