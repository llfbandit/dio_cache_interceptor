import 'package:http_cache_core/http_cache_core.dart';
import 'package:http_cache_mmkv_store/src/store/cache_response_adaptor.dart';
import 'package:mmkv/mmkv.dart';

/// A store saving responses using MMKV.
///
class MMKVCacheStore extends CacheStore {
  /// Creates a new MMKV-based cache store.
  ///
  /// IMPORTANT: MMKV must be initialized before creating any instances.
  /// Use [MMKVCacheStore.initialize()] or initialize MMKV directly before
  /// constructing this store.
  ///
  /// Parameters:
  /// - [cryptKey]: Optional encryption key. If provided, the cache data will be
  ///   encrypted using this key.
  MMKVCacheStore({
    String? cryptKey,
  }) : _mmkv = MMKV.defaultMMKV(cryptKey: cryptKey);

  /// Useful for testing purposes.
  /// Allows injecting a mock MMKV instance for testing and dependency injection.
  MMKVCacheStore.fromMMKV(MMKV mmkv) : _mmkv = mmkv;

  final MMKV _mmkv;

  /// Initializes MMKV storage for caching if not already initialized in your app.
  ///
  /// MMKV requires initialization before usage. You can initialize it in two ways:
  ///
  /// 1. Using MMKV directly:
  /// ```dart
  /// import 'package:mmkv/mmkv.dart';
  ///
  /// void main() async {
  ///   // Initialize MMKV and get the root directory
  ///   final rootDir = await MMKV.initialize();
  ///   print('MMKV initialized with rootDir: $rootDir');
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// 2. Using MMKVCacheStore convenience method:
  /// ```dart
  /// import 'package:http_cache_mmkv_store/http_cache_mmkv_store.dart';
  ///
  /// void main() async {
  ///   // Initialize MMKV through MMKVCacheStore
  ///   final rootDir = await MMKVCacheStore.initialize();
  ///   print('MMKVCacheStore initialized with rootDir: $rootDir');
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// Both approaches are equivalent - choose the one that better fits your codebase.
  /// The initialization must complete before using any MMKV functionality.
  static Future<String> initialize({
    String? rootDir,
    String? groupDir,
    MMKVLogLevel logLevel = MMKVLogLevel.Info,
    MMKVHandler? handler,
  }) =>
      MMKV.initialize(
        groupDir: groupDir,
        rootDir: rootDir,
        logLevel: logLevel,
        handler: handler,
      );

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    final keys = <String>[];

    for (final key in _mmkv.allKeys) {
      final resp = await get(key);

      if (resp != null) {
        var shouldRemove = resp.priority.index <= priorityOrBelow.index;
        shouldRemove &= (staleOnly && resp.isStaled()) || !staleOnly;

        if (shouldRemove) {
          keys.add(resp.key);
        }
      }
    }

    if (keys.isNotEmpty) {
      _mmkv.removeValues(keys);
    }
  }

  @override
  Future<void> close() async {
    _mmkv.close();
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    if (!staleOnly) {
      _mmkv.removeValue(key);
      return;
    }

    final response = await get(key);
    if (response?.isStaled() == true) {
      _mmkv.removeValue(key);
    }
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final responses = await getFromPath(pathPattern, queryParams: queryParams);
    final keys = responses.map((r) => r.key).toList();
    if (keys.isNotEmpty) {
      _mmkv.removeValues(keys);
    }
  }

  @override
  Future<bool> exists(String key) async {
    return _mmkv.containsKey(key);
  }

  @override
  Future<CacheResponse?> get(String key) async {
    final bytes = _mmkv.decodeBytes(key);
    if (bytes == null) return null;

    final response = CacheResponseAdaptor.cacheResponseFromMMBuffer(bytes);
    bytes.destroy();
    return response;
  }

  @override
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final allKeys = _mmkv.allKeys;

    return allKeys
        .map((key) {
          final bytes = _mmkv.decodeBytes(key);
          if (bytes == null) return null;

          final response =
              CacheResponseAdaptor.cacheResponseFromMMBuffer(bytes);
          bytes.destroy();
          return response;
        })
        .whereType<CacheResponse>()
        .where((response) =>
            pathExists(response.url, pathPattern, queryParams: queryParams))
        .toList();
  }

  @override
  Future<void> set(CacheResponse response) async {
    final buffer = CacheResponseAdaptor.cacheResponseToMMBuffer(response);
    _mmkv.encodeBytes(response.key, buffer);
    buffer?.destroy();
  }
}
