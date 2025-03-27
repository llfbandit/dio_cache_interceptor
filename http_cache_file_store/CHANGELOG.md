## 2.0.0
- feat: Saves response status code.
- chore: Updated dependencies.

## 1.2.3
- chore: Updated dependencies.

## 1.2.2
- chore: Updated dependencies.

## 1.2.1
- fix: Wrongly awaited `clean` method.
- fix: Wrongly awaited `getFromPath` method.

## 1.2.0
- feat: Add `Store.getFromPath` method.
- feat: Add `Store.deleteFromPath` method.

## 1.1.0
- Add request date to stored values.
- Raise dio_cache_interceptor minimum version.

## 1.0.0
- Initial release as external package.
- Fixes concurrent access to files. Operations are locked per keys.
- Web implementation doesn't throw exceptions anymore. Returns null or false result instead.
