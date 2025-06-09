[![pub package](https://img.shields.io/pub/v/dio_cache_interceptor.svg)](https://pub.dev/packages/dio_cache_interceptor)
[![codecov](https://codecov.io/gh/llfbandit/dart_http_cache/graph/badge.svg?token=QQQIXO7VZI)](https://codecov.io/gh/llfbandit/dart_http_cache)

Dio HTTP cache interceptor with multiple stores respecting HTTP directives (or not).

Also available as client for [http](https://pub.dev/packages/http_cache_client) package.

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
- __DriftCacheStore__: Cache with Drift [Get it](https://pub.dev/packages/http_cache_drift_store).
- __FileCacheStore__: Cache with file system (Does nothing on web platform) [Get it](https://pub.dev/packages/http_cache_file_store).
- __HiveCacheStore__: Cache using hive_ce package [Get it](https://pub.dev/packages/http_cache_hive_store).
- __IsarCacheStore__: Cache using Isar package (available on all platforms) [Get it](https://pub.dev/packages/http_cache_isar_store).
- __ObjectBoxCacheStore__: Cache using ObjectBox package (no web support) [Get it](https://pub.dev/packages/http_cache_objectbox_store).
- __SembastCacheStore__: Cache using Sembast package [Get it](https://pub.dev/packages/http_cache_sembast_store).
- __MMKVCacheStore__: Cache using MMKV package (iOS & Android only) [Get it](https://pub.dev/packages/http_cache_mmkv_store).
- __MemCacheStore__: Volatile cache with LRU strategy.

## Usage

```dart
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

// Global options
final options = const CacheOptions(
  // A default store is required for interceptor.
  store: MemCacheStore(),

  // All subsequent fields are optional to get a standard behaviour.
  
  // Default.
  policy: CachePolicy.request,
  // Returns a cached response on error for given status codes.
  // Defaults to `[]`.
  hitCacheOnErrorCodes: [500],
  // Allows to return a cached response on network errors (e.g. offline usage).
  // Defaults to `false`.
  hitCacheOnNetworkFailure: true,
  // Overrides any HTTP directive to delete entry past this duration.
  // Useful only when origin server has no cache config or custom behaviour is desired.
  // Defaults to `null`.
  maxStale: const Duration(days: 7),
  // Default. Allows 3 cache sets and ease cleanup.
  priority: CachePriority.normal,
  // Default. Body and headers encryption with your own algorithm.
  cipher: null,
  // Default. Key builder to retrieve requests.
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  // Default. Allows to cache POST requests.
  // Assigning a [keyBuilder] is strongly recommended when `true`.
  allowPostMethod: false,
);

// Add cache interceptor with global/default options
final dio = Dio()..interceptors.add(DioCacheInterceptor(options: options));

// ...

// Requesting with global options => status(200) => Content is written to cache store.
var response = await dio.get('https://www.foo.com');
// Requesting with global options => status(304 => 200) => Content is read from cache store.
response = await dio.get('https://www.foo.com');

// Requesting by modifying policy with refresh option
// for this single request => status(200) => Content is written to cache store.
response = await dio.get('https://www.foo.com',
  options: options.copyWith(policy: CachePolicy.refresh).toOptions(),
);
```

## Handling cache with client only
Follow those [intructions](https://github.com/llfbandit/dart_http_cache/wiki/Handling-cache-with-client-only) if needed.

## Options
`CacheOptions` is widely available on interceptor and on requests to take precedence.  

See [documentation](https://pub.dev/documentation/dio_cache_interceptor/latest/dio_cache_interceptor/dio_cache_interceptor-library.html) for all properties.

### Encryption
Optionally, you can encrypt body and headers with your own algorithm via `CacheCipher`.

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/llfbandit/dart_http_cache/issues).

## License

[License](https://github.com/llfbandit/dart_http_cache/blob/master/dio_cache_interceptor/LICENSE).
