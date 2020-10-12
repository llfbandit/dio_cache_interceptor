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
