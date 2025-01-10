## 6.0.0
- feat: Updated dependencies for make this package compatible with WASM.
- feat: Improved `deleteFromPath` and `getFromPath` methods to retrieve multiple entries.
- fix: `exists` method was not returning result from filtered key.
- chore: Raised Dart SDK to ^3.0.0.
- chore: Raised Drift to ^2.9.0.

## 5.1.1
- chore: Updated dependencies.

## 5.1.0
- core: Upgrade to Drift 2.5.
- core: Use Drift `createBackgroundConnection` to handle background DB connection.
- fix: Forward `logStatements` parameter when on desktop.
- chore: Now download SQLite from remote before running tests.

## 5.0.0
- core: `Drift` version 2 upgrade.

## 4.2.1
- fix: Un-awaited `Store.getFromPath` method.

## 4.2.0
- feat: Add `Store.getFromPath` method.
- feat: Add `Store.deleteFromPath` method.

## 4.1.1
- core: Drift database re-generation to get rid of `Missing concrete implementation of 'getter ResultSetImplementation.attachedDatabase'.` message on pub.dev.

## 4.1.0
- Add request date to stored values.
- Raise dio_cache_interceptor minimum version.

## 4.0.0
- core: Moor to Drift upgrade.
- core: Updated dependencies.

## 3.0.2
- core: update dependencies. `Moor` minimal version is now ^4.4.1.
- core: regenerate database.g.dart with `Moor` 4.4.1. [#32](https://github.com/llfbandit/dio_cache_interceptor/issues/32)

## 3.0.1
- fix: imports.

## 3.0.0
- Initial release.