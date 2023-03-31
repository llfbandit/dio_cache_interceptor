[![pub package](https://img.shields.io/pub/v/dio_cache_interceptor.svg)](https://pub.dev/packages/dio_cache_interceptor)
[![codecov](https://codecov.io/gh/llfbandit/dio_cache_interceptor/branch/master/graph/badge.svg?token=QQQIXO7VZI)](https://codecov.io/gh/llfbandit/dio_cache_interceptor)

Dio HTTP cache interceptor with multiple stores respecting HTTP directives (or not).

## HTTP directives:
|                   |                                                           |
|-------------------|-----------------------------------------------------------|
| Cache triggers    | ETag                                                      |
|                   | Last-Modified                                             |
|                   | Date                                                      |
| Cache freshness   | Age                                                       |
|                   | Date                                                      |
|                   | Expires                                                   |
|                   | max-age (Cache-Control)                                   |
|                   | max-stale (Cache-Control)                                 |
|                   | min-fresh (Cache-Control)                                 |
|                   | must-revalidate                                           |
|                   | Request date (added by interceptor)                       |
|                   | Response date (added by interceptor)                      |
| Cache commutators | no-cache (Cache-Control)                                  |
|                   | no-store (Cache-Control request & response)               |

## Stores
- __BackupCacheStore__: Combined store with primary and secondary.
- __DbCacheStore__: Cache with database (Drift) [Get it](https://pub.dev/packages/dio_cache_interceptor_db_store).
- __FileCacheStore__: Cache with file system (Does nothing on web platform) [Get it](https://pub.dev/packages/dio_cache_interceptor_file_store).
- __HiveCacheStore__: Cache using Hive package (available on all platforms) [Get it](https://pub.dev/packages/dio_cache_interceptor_hive_store).
- __ObjectBoxCacheStore__: Cache using ObjectBox package (no web support) [Get it](https://pub.dev/packages/dio_cache_interceptor_objectbox_store).
- __SembastCacheStore__: Cache using Sembast package [Get it](https://pub.dev/packages/dio_cache_interceptor_sembast_storage).
- __MemCacheStore__: Volatile cache with LRU strategy.

## Usage

```dart
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

// Global options
final options = const CacheOptions(
  // A default store is required for interceptor.
  store: MemCacheStore(),

  // All subsequent fields are optional.
  
  // Default.
  policy: CachePolicy.request,
  // Returns a cached response on error but for statuses 401 & 403.
  // Also allows to return a cached response on network errors (e.g. offline usage).
  // Defaults to [null].
  hitCacheOnErrorExcept: [401, 403],
  // Overrides any HTTP directive to delete entry past this duration.
  // Useful only when origin server has no cache config or custom behaviour is desired.
  // Defaults to [null].
  maxStale: const Duration(days: 7),
  // Default. Allows 3 cache sets and ease cleanup.
  priority: CachePriority.normal,
  // Default. Body and headers encryption with your own algorithm.
  cipher: null,
  // Default. Key builder to retrieve requests.
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  // Default. Allows to cache POST requests.
  // Overriding [keyBuilder] is strongly recommended when [true].
  allowPostMethod: false,
  // handle not-modified status in response flow
  // This allows following response interceptors to still be called
  callResponseInterceptorsAfterNotModified: false,
);

// Add cache interceptor with global/default options
final dio = Dio()..interceptors.add(DioCacheInterceptor(options: options));

// ...

// Requesting with global options => status(200) => Content is written to cache store
var response = await dio.get('https://www.foo.com');
// Requesting with global options => status(304) => Content is read from cache store
response = await dio.get('https://www.foo.com');

// Requesting by modifying policy with refresh option
// for this single request => status(200) => Content is written to cache store
response = await dio.get('https://www.foo.com',
  options: options.copyWith(policy: CachePolicy.refresh).toOptions(),
);
```

## Handling cache with client only
Follow those [intructions](https://github.com/llfbandit/dio_cache_interceptor/wiki/Handling-cache-with-client-only) if needed.

## Options
`CacheOptions` is widely available on interceptor and on requests to take precedence.  

See [documentation](https://pub.dev/documentation/dio_cache_interceptor/latest/dio_cache_interceptor/dio_cache_interceptor-library.html) for all properties.

### Encryption
Optionally, you can encrypt body and headers with your own algorithm via `CacheCipher`.

### Cache policy
```dart
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
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/llfbandit/dio_cache_interceptor/issues

## License

[License](https://github.com/llfbandit/dio_cache_interceptor/blob/master/LICENSE).
