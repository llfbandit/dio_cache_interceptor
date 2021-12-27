import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class FileCacheStore implements CacheStore {
  FileCacheStore(String directory);

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) {
    return Future.value();
  }

  @override
  Future<void> close() {
    return Future.value();
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) {
    return Future.value();
  }

  @override
  Future<bool> exists(String key) {
    return Future.value(false);
  }

  @override
  Future<CacheResponse?> get(String key) {
    return Future.value();
  }

  @override
  Future<void> set(CacheResponse response) {
    return Future.value();
  }
}
