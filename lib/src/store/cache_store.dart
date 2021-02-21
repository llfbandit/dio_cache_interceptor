import '../model/cache_priority.dart';
import '../model/cache_response.dart';

/// Definition of store
abstract class CacheStore {
  /// Checks if key exists in store
  Future<bool> exists(String key);

  /// Retrieves cached response from store
  Future<CacheResponse> get(String key);

  /// Pushes response in store
  Future<void> set(CacheResponse response);

  /// Removes the given key from store.
  /// [staleOnly] flag will remove it only if the key is expired
  /// (from maxStale).
  Future<void> delete(String key, {bool staleOnly = false});

  /// Removes all keys from store.
  /// [priorityOrBelow] flag will remove keys only for the priority or below.
  /// [staleOnly] flag will remove keys only if expired
  /// (from maxStale).
  ///
  /// By default, all keys will be removed.
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  });

  /// Releases underlying resources (if any)
  Future<void> close();
}
