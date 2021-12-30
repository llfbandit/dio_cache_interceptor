## 1.1.0
- Add request date to stored values.
- Raise dio_cache_interceptor minimum version.

## 1.0.0
- Initial release as external package.
- Fixes concurrent access to files. Operations are locked per keys.
- Web implementation doesn't throw exceptions anymore. Returns null or false result instead.
