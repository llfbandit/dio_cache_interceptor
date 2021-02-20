Dio HTTP cache interceptor with multiple stores respecting HTTP directives (or not).

## HTTP directives:
- ETag
- Last-Modified
- Cache-Control
- Date
- Expires

## Stores
- BackupCacheStore: Combined store with primary and secondary.
- DbCacheStore: Cache with database (Moor).
- FileCacheStore: Cache with file system.
- MemCacheStore: Volatile cache with LRU strategy.

## Web support:
- For DbCacheStore, you must include 'sql.js' library. Follow Moor install [documentation](https://moor.simonbinder.eu/web/) for further info.
- FileCacheStore is obviously not supported on web platform.

## DbCacheStore - Desktop support:
- Follow Moor install [documentation](https://moor.simonbinder.eu/docs/platforms/).

## Usage

```dart
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

// Global options
final options = const CacheOptions(
  store: DbCacheStore(), // Required.
  policy: CachePolicy.requestFirst, // Default. Requests first and caches response.
  hitCacheOnErrorExcept: [401, 403], // Optional. Returns a cached response on error if available but for statuses 401 & 403.
  priority: CachePriority.normal, // Optional. Default. Allows 3 cache levels and ease cleanup.
  maxStale: const Duration(days: 7), // Very optional. Overrides any HTTP directive to delete entry past this duration.
);

// Add cache interceptor with global/default options
final dio = Dio()
  ..interceptors.add(DioCacheInterceptor(options: options),
);

...

// Request with default options
var response = await dio.get('http://www.foo.com');

// Request with dedicated options
response = await dio.get('http://www.foo.com',
  options: Options(
    extra: CacheOptions(policy: CachePolicy.refresh).toExtra(),
  ),
);
```

## Options
`CacheOptions` are widely available on interceptor and on requests to take precedence.  
There is no merge behaviour between interceptor and dedicated request options but store property.

See [documentation](https://pub.dev/documentation/dio_cache_interceptor/latest/dio_cache_interceptor/dio_cache_interceptor-library.html) for all properties.

### Encryption
Optionally, you can encrypt content and headers with your own algorithm via `Encrypt` / `Decrypt` methods if your storage is located in public folder.

### Cache policy
```dart
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
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/llfbandit/dio_cache_interceptor/issues

### Testing
From example folder:
```sh
flutter run test/test_suite.dart
```

## License

[License](https://github.com/llfbandit/dio_cache_interceptor/blob/master/LICENSE).