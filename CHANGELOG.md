## 2.0.0-rc.1
- core: Update dio to 4.0.0-prev1.
- fix: update cache header values on 304 (keeping in sync freshness of our cache content).
- fix: return cache on socket exception with hitCacheOnErrorExcept.
- fix: date header parsing exception not catched.

## 2.0.0-beta.7
- core: Update dio to 4.0.0-beta7.
- __Breaking__: Remove now useless/confusing `cacheFirst` policy with improved freshness checks.
- __Breaking__: Rename `requestFirst` to `request`.
- Small code improvements.
- Update README.MD

## 2.0.0-beta.6
- core: Update dio to 4.0.0-beta6.
- Small code improvement / clean-up.
- Feat: Add boolean `fromNetwork` to extra in `Response`.
- Fix: Cache-Control max-age precedence over Expires header.
- Completed test coverage.
- Now waiting for Dio to get out of beta stage or issue reports!

## 2.0.0-beta.5
- core: Update dio to 4.0.0-beta5.
- Wrap decrypt/encrypt functions to `CacheCipher`.
- Add decent test coverage (still WIP).

## 2.0.0-beta.4
- core: Update dio to 4.0.0-beta4.
- Add missing `copyWith` method in `CacheOptions` to allow single option change.
- Small improvements & fixes

## 2.0.0-beta.3
- core: Support null safety

## 2.0.0-beta.2
- fix: Hide FileCacheStore for web support.
- core: Remove flutter dependency.

## 2.0.0-beta.1
- __Breaking__: Moved from sqflite to Moor(:ffi) package for DbCacheStore.
- __Breaking__: Data stored with DbCacheStore is not compatible with previous versions.
- feat: Open support for linux, macOS, Windows and web platforms.
- core: Updated code to get rid of dart:io package for web platform.

## 1.0.0
- core: Same version as 0.6.0. Updating dependencies.
- core: Add missing analysis pedantic file.
- fix: Remaining minor warnings.
- core: No known issue. Bump to 1.0 to be prepared for null safety version.

## 0.6.0
- feat: Add `Cache-control` header for response directives (all values are stored).
- feat: Add `Date` header.
- feat: Add `Expires` header (if date is invalid (i.e. 0), date is considered expired to 1970-01-01).
- feat: Cached response is now stored with absolute date (also used for max-age calculation).
- feat: `CacheStore` is no more required in `CacheOptions` to ease subsequent requests with global options.
- feat: `Response` object has now `CacheResponse.fromCache: true` extra boolean if coming from cache with `CacheResponse.cacheKey`.
- fix: `Response` extra are no more concatenated with `RequestOptions` extra (use `Response.request.extra` for this).
- fix(wording): `stalledOnly` renamed to `staleOnly` in `CacheStore`.
- various minor fixes and improvements.

Note:  
This version should be backward compatible (data related) with 0.5.x versions (Please report any issues).  
Even so, you're advised to clean stores to refresh entries with new headers.

With this version, 1.0 should be around the corner.

## 0.5.1
- fix: ETag conditional requesting with If-None-Match (Thanks @live9080).
- Update README.MD

## 0.5.0
- feat: add backup cache store
- core: add stores testing
- fix: file store associated fixes

## 0.4.0

- Add MemCacheStore. Cache with LRU strategy on RAM.
- Re-add 'exists' store method.
- Multiple fixes on maxStale (purge, get/set)
- Various cleanups.

## 0.3.0

- Add decrypt/encrypt methods to CacheOptions (no encryption by default. Private directories for stores are prefered for common usage).
- Remove 'exists' store method.

## 0.2.0

- Cancelled.

## 0.1.0

- Initial version
- DB cache store
- File cache store
- ETag
- Last-Modified
- Max stale
- CacheOptions
