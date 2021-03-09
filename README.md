[![codecov](https://codecov.io/gh/llfbandit/dio_cache_interceptor/branch/master/graph/badge.svg?token=QQQIXO7VZI)](https://codecov.io/gh/llfbandit/dio_cache_interceptor)

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
- FileCacheStore: Cache with file system (no web support obviously).
- MemCacheStore: Volatile cache with LRU strategy.

### DbCacheStore:
#### Android - iOS support:
- Add sqlite3_flutter_libs as dependency in your app (version 0.4.0+1 or later).

#### Desktop support:
- Follow Moor install [documentation](https://moor.simonbinder.eu/docs/platforms/).

#### Web support:
- You must include 'sql.js' library. Follow Moor install [documentation](https://moor.simonbinder.eu/web/) for further info.

## Usage

```dart
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

// Global options
final options = const CacheOptions(
  store: DbCacheStore(databasePath: 'a_path'), // Required.
  policy: CachePolicy.request, // Default. Checks cache freshness, requests otherwise and caches response.
  hitCacheOnErrorExcept: [401, 403], // Optional. Returns a cached response on error if available but for statuses 401 & 403.
  priority: CachePriority.normal, // Optional. Default. Allows 3 cache sets and ease cleanup.
  maxStale: const Duration(days: 7), // Very optional. Overrides any HTTP directive to delete entry past this duration.
);

// Add cache interceptor with global/default options
final dio = Dio()
  ..interceptors.add(DioCacheInterceptor(options: options),
);

// ...

// Requesting with global options => status code(200)
var response = await dio.get('http://www.foo.com');
// Requesting with global options => status code(304)
response = await dio.get('http://www.foo.com');

// Requesting with dedicated options => status code(200)
response = await dio.get('http://www.foo.com',
  options: options.copyWith(policy: CachePolicy.refresh).toOptions(),
);
```

## Options
`CacheOptions` is widely available on interceptor and on requests to take precedence.  

See [documentation](https://pub.dev/documentation/dio_cache_interceptor/latest/dio_cache_interceptor/dio_cache_interceptor-library.html) for all properties.

### Encryption
Optionally, you can encrypt body and headers with your own algorithm via `CacheCipher`.

### Cache policy
```dart
enum CachePolicy {
  /// Forces to return the cached value if available.
  /// Requests otherwise.
  /// Caches response regardless directives.
  ///
  /// In short, you'll save every successful GET requests.
  /// This should not be combined with maxStale.
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

  /// Returns the cached value if available (and un-expired).
  /// Requests otherwise and caches if response has directives.
  request,
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/llfbandit/dio_cache_interceptor/issues

## License

[License](https://github.com/llfbandit/dio_cache_interceptor/blob/master/LICENSE).