import '../model/cache_priority.dart';
import '../model/cache_response.dart';

/// Definition of store
abstract class CacheStore {
  /// Check if key exists in store
  Future<bool> exists(String key);

  /// Retrieve cached response from store
  Future<CacheResponse> get(String key);

  /// Push response in store
  Future<void> set(CacheResponse response);

  /// Remove the given key from store.
  /// [stalledOnly] flag will remove it only if the key is expired
  /// (from maxStale).
  Future<void> delete(String key, {bool stalledOnly = false});

  /// Remove all keys from store.
  /// [priorityOrBelow] flag will remove keys only for the priority or below.
  /// [stalledOnly] flag will remove keys only if expired
  /// (from maxStale).
  ///
  /// By default, all keys will be removed.
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool stalledOnly = false,
  });
}
