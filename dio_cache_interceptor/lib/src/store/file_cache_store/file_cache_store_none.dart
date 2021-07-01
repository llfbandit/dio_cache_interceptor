import 'package:dio_cache_interceptor/src/model/cache_priority.dart';
import 'package:dio_cache_interceptor/src/model/cache_response.dart';
import 'package:dio_cache_interceptor/src/store/cache_store.dart';

class FileCacheStore implements CacheStore {
  FileCacheStore(String directory);

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> close() {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> exists(String key) {
    throw UnimplementedError();
  }

  @override
  Future<CacheResponse?> get(String key) {
    throw UnimplementedError();
  }

  @override
  Future<void> set(CacheResponse response) {
    throw UnimplementedError();
  }
}
