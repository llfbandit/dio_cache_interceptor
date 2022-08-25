import '../model/cache_priority.dart';
import '../model/cache_response.dart';

/// Definition of store
abstract class CacheStore {
  /// Checks if key exists in store
  Future<bool> exists(String key);

  /// Retrieves cached response from the given key.
  Future<CacheResponse?> get(String key);

  /// Retrieves cached responses from a path pattern.
  ///
  /// [pathPattern] path pattern (e.g. RegExp('https://www.example.com/a/b') or
  /// RegExp(r'https://www.example.com/a/\d+)).
  ///
  /// [queryParams] filter is processed in the following way:
  /// - null: all entries are collected,
  /// - null value: all entries containing the key are collected,
  /// - otherwise key/value match only.
  ///
  /// You should be very restrictive when using this method as the underlying
  /// store may parse and load all data from the store.
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  });

  /// Pushes response in store
  Future<void> set(CacheResponse response);

  /// Removes the given key from store.
  /// [staleOnly] flag will remove it only if the key is expired
  /// (from maxStale).
  Future<void> delete(String key, {bool staleOnly = false});

  /// Removes keys from the given filters.
  ///
  /// [pathPattern] path pattern (e.g. RegExp('https://www.example.com/a/b') or
  /// RegExp(r'https://www.example.com/a/\d+)).
  ///
  /// [queryParams] filter is processed in the following way:
  /// - null: all entries are collected,
  /// - null value: all entries containing the key are collected,
  /// - otherwise key/value match only.
  ///
  /// You should be very restrictive when using this method as the underlying
  /// store may parse and load all data from the store.
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  });

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

  /// Checks if the given url matches with the given filters.
  /// [url] must conform to uri parsing.
  bool pathExists(
    String url,
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) {
    if (!pathPattern.hasMatch(url)) return false;

    var hasMatch = true;

    final uri = Uri.parse(url);
    if (queryParams != null) {
      for (final entry in queryParams.entries) {
        hasMatch &= uri.queryParameters.containsKey(entry.key);
        if (entry.value != null) {
          hasMatch &= uri.queryParameters[entry.key] == entry.value;
        }
        if (!hasMatch) break;
      }
    }

    return hasMatch;
  }
}
