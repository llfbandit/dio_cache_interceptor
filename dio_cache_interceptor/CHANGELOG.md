## 3.4.4
- chore: Allow UUID package version v4.x

## 3.4.3
- fix: Correctly sierialize null content responses.
- chore: explicitly allow dart 3.
- chore: Now requires Dio >= 5.2.0+1.

## 3.4.2
- fix: Headers were not saved/restored in/from `CacheResponse`.
- fix: Cache trigger now enabled again with `expires`, `Cache-Control`/`max-age`.
- feat: Add few new status codes available for caching: 404, 405 and 501.
- chore: Few code improvements.

## 3.4.1
- chore: Ensure header values are join when there's comma (,) in the value (date, expires, last-modified, etag).
Dio may or may not understand headers with single value (i.e.: 'Wed, 21 Oct 2015 07:28:00 GMT').

## 3.4.0
- chore: Allow dio version 5 aside version 4.

## 3.3.1
- fix: pathExists queryParams are not checked correctly (thanks to @clragon)

## 3.3.0
- feat: Add `Store.getFromPath` method.
- feat: Add `Store.deleteFromPath` method.  
Those two methods allow advanced manipulation of entries in store.  
Ensure to be restrictive when using it.

## 3.2.7
- fix: read/write when cipher is used.
- core: Avoids some roundtrips resulting in improved performance.
- feat: (Re-)introduce `copyWith` on `CacheResponse`.
- core: Remove Android example deprecations.

## 3.2.6
- feat: Don't skip subsequent `onResponse` interceptors if any.

## 3.2.5
- fix: Cache control parsing on request. Dio request headers are not of type `Headers`.

## 3.2.4
- fix: Missing `Nullable` export.

## 3.2.3
- __Breaking__ feat: `CacheOptions.copyWith` now requires `Nullable` for some parameters to allow `null` values.
- fix: Since version 3.2.0, when `maxStale` was set on global options, it was necessary to re-create the dedicated `CacheOptions` for the request to avoid postponing. You can now use the changed copyWith to do that.
- fix: `MemCacheStore.close` now clears all entries.
- fix: size computation of entry bytes in `MemCacheStore`.

## 3.2.2
- fix: stream response type is no more eligible to cache (wasn't working anyway). This is additional fix to `content-disposition: attachment; ...` since headers may not be set.

## 3.2.1
- fix: io import in CacheResponse preventing usage with web platform.

## 3.2.0
>Warning, this version is considered compatible with previous versions about stored data.  
>However, cache store entries have now a new field for request
>date persistence which is setup arbitrarily for backward compatibility (150ms before response receive time).  
>Depending of your usage, cache beheviour could be a bit inaccurate while entries are not updated with new strategy algorithm.  
>If this is critical for your app, consider to clean up your store by calling `store.clean();` for example on your next app upgrade.

- feat: More status codes (203, 301) are available for caching responses.
- feat: Status codes (302 are 307) are available for caching responses under strict conditions.
- feat: Lots of improvements in computation of response expiry. Package is now much more compliant with `rfc7234`.
- feat: `age`, `max-stale`, `min-fresh`, `must-revalidate` headers/values are now parsed.
- feat: When `maxStale` is given to the request, interceptor will now add/update it from the current date for a previously cached response. This lets you get more control to postpone the deletion if needed.
- fix: stale state is now handled in interceptor instead of cache stores.
- fix: `no-cache` header is now correctly handled.
- fix: `content-disposition: attachment; ...` is no more eligible to be cached.
- core: General code cleanup to handle above features.

## 3.1.0
- __Breaking__: File cache store is now available as external package and suitable for production.
- Improved example with added non-cached content & image provider sample.

## 3.0.3
- fix: Cipher file export.
- feat: Add ObjectBox store (All credits go to [cmengler](https://github.com/cmengler)).

## 3.0.2
- fix: Ciphered content deserialization error when updating headers.

## 3.0.1
- fix: file_cache_store visibility.

## 3.0.0
- core: Moved DB & Hive cache stores to their respective packages.
- fix: import of file_cache_store.

## 2.3.1
- fix: Cache-Control parsing. Dio does not expand multi valued headers.

## 2.3.0
- feat: `allowPostMethod` added to `CacheOptions`.

## 2.2.0
- feat: Cache-Control: max-age as cache trigger added.
- core: update README.md.

## 2.1.1
- fix: refreshForceCache policy added.
Get parity with refresh/request and refreshForceCache/forceCache.

## 2.1.0
- feat: Add Hive as cache store.

## 2.0.0
- core: Update dio to 4.0.0.
- Renamed `cacheStoreForce` to `forceCache`.
- Renamed `cacheStoreNo` to `noCache`.
- Make `CacheOptions.store` required but still with optional value.

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
