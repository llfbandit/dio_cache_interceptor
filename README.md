[![codecov](https://codecov.io/gh/llfbandit/dio_cache_interceptor/branch/master/graph/badge.svg?token=QQQIXO7VZI)](https://codecov.io/gh/llfbandit/dio_cache_interceptor)

Dio HTTP cache interceptor with multiple stores respecting HTTP directives (or not).

## HTTP directives:
|                   |                                |
|-------------------|--------------------------------|
| Cache triggers    | ETag                           |
|                   | Last-Modified                  |
|                   | max-age (Cache-Control)        |
| Cache freshness   | Date (response date otherwise) |
|                   | Expires                        |
|                   | max-age (Cache-Control)        |
| Cache commutators | no-cache (Cache-Control)       |
|                   | no-store (Cache-Control)       |

## Stores
- __BackupCacheStore__: Combined store with primary and secondary.
- __DbCacheStore__: Cache with database (Moor).
- __FileCacheStore__: Cache with file system (no web support obviously).
- __HiveCacheStore__: Cache using Hive package (available on all platforms).
- __MemCacheStore__: Volatile cache with LRU strategy.

### DbCacheStore:
- __Android - iOS support__: Add sqlite3_flutter_libs as dependency in your app (version 0.4.0+1 or later).
- __Desktop support__: Follow Moor install [documentation](https://moor.simonbinder.eu/docs/platforms/).
- __Web support__: You must include 'sql.js' library. Follow Moor install [documentation](https://moor.simonbinder.eu/web/) for further info.

## Usage

```dart
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

// Global options
final options = const CacheOptions(
  // A default store is required for interceptor.
  store: MemCacheStore(),
  // Default.
  policy: CachePolicy.request,
  // Optional. Returns a cached response on error but for statuses 401 & 403.
  hitCacheOnErrorExcept: [401, 403],
  // Optional. Overrides any HTTP directive to delete entry past this duration.
  maxStale: const Duration(days: 7),
  // Default. Allows 3 cache sets and ease cleanup.
  priority: CachePriority.normal,
  // Default. Body and headers encryption with your own algorithm.
  cipher: null,
  // Default. Key builder to retrieve requests.
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  // Default. Allows to cache POST requests.
  // Overriding [keyBuilder] is strongly recommended.
  allowPostMethod: false,
);

// Add cache interceptor with global/default options
final dio = Dio()..interceptors.add(DioCacheInterceptor(options: options));

// ...

// Requesting with global options => status(200)
var response = await dio.get('http://www.foo.com');
// Requesting with global options => status(304)
response = await dio.get('http://www.foo.com');

// Requesting by modifying policy with refresh option
// for this single request => status(200)
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
  forceCache,

  /// Requests regardless cache availability.
  /// Caches response regardless directives.
  ///
  /// In short, you'll save every successful GET requests.
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
  /// with returned headers.
  ///
  /// Requests otherwise and caches if response has directives.
  request,
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/llfbandit/dio_cache_interceptor/issues

## License

[License](https://github.com/llfbandit/dio_cache_interceptor/blob/master/LICENSE).