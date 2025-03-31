[![pub package](https://img.shields.io/pub/v/http_cache_drift_store.svg)](https://pub.dev/packages/http_cache_drift_store)

# http_cache_drift_store

Drift cache store implementation for:
 - [dio](https://pub.dev/packages/dio_cache_interceptor)
 - [http](https://pub.dev/packages/http_cache_client)

- __Android - iOS support__: Add sqlite3_flutter_libs as dependency in your app (version 0.4.0+1 or later).
- __Desktop support__: Follow Drift install [documentation](https://drift.simonbinder.eu/docs/platforms/).
- __Web support__:
  - You __must__ provide 'sqlite3.wasm' library and 'drift_worker.js'.
  - Those aren't shipped with the package to allow you unsynced upgrades regarding this package since `Drift` dependency is not pinned.
  - Follow Drift install [documentation](https://drift.simonbinder.eu/web/) for further info.
