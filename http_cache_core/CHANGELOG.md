## 1.1.1
- fix: Send only one condition on request cache validation.

## 1.1.0
- feat: Early skip strategy calculation when request has already cache check conditions.
- feat: Better handling of headers.
- feat: Clamp cache-control values and other headers.
- fix: Regression from versions 1.0.1 with `CacheOptions#maxStale` inverted behaviour.
- chore: Add more comments.
- chore: Add more tests & fix some.

## 1.0.2
- fix: Enforce `CacheKeyBuilder` headers as map of `String` values instead of `dynamic`.

## 1.0.1
- chore: Add writeContent to CacheResponse.
- fix: `CacheOptions#maxStale` usage may lead to empty response body.
- chore: Allow to read only headers or body.

## 1.0.0
- Initial version.
