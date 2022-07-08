import '../../dio_cache_interceptor.dart';

/// A store saving responses in a dedicated memory LRU map.
///
class MemCacheStore extends CacheStore {
  final _LruMap _cache;

  /// [maxSize]: Total allowed size in bytes (7MB by default).
  ///
  /// [maxEntrySize]: Allowed size per entry in bytes (500KB by default).
  ///
  /// To prevent making this store useless, be sure to
  /// respect the following lower-limit rule: maxEntrySize * 5 <= maxSize.
  ///
  MemCacheStore({
    int maxSize = 7340032,
    int maxEntrySize = 512000,
  }) : _cache = _LruMap(maxSize: maxSize, maxEntrySize: maxEntrySize);

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) {
    final keys = <String>[];

    _cache.entries.forEach((key, resp) {
      var shouldRemove = resp.value.priority.index <= priorityOrBelow.index;
      shouldRemove &= (staleOnly && resp.value.isStaled()) || !staleOnly;

      if (shouldRemove) {
        keys.add(key);
      }
    });

    for (var key in keys) {
      _cache.remove(key);
    }

    return Future.value();
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) {
    final resp = _cache.entries[key];
    if (resp == null) return Future.value();

    if (staleOnly && !resp.value.isStaled()) {
      return Future.value();
    }

    _cache.remove(key);

    return Future.value();
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final responses = await getFromPath(
      pathPattern,
      queryParams: queryParams,
    );

    for (final response in responses) {
      _cache.remove(response.key);
    }
  }

  @override
  Future<bool> exists(String key) {
    return Future.value(_cache.entries.containsKey(key));
  }

  @override
  Future<CacheResponse?> get(String key) async {
    return _cache[key];
  }

  @override
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final responses = <CacheResponse>[];

    for (final entry in _cache.entries.entries) {
      final resp = entry.value.value;
      if (pathExists(resp.url, pathPattern, queryParams: queryParams)) {
        responses.add(resp);
      }
    }

    return responses;
  }

  @override
  Future<void> set(CacheResponse response) {
    _cache.remove(response.key);
    _cache[response.key] = response;

    return Future.value();
  }

  @override
  Future<void> close() {
    _cache.clear();
    return Future.value();
  }
}

class _LruMap {
  _Link? _head;
  _Link? _tail;

  final entries = <String, _Link>{};

  int _currentSize = 0;
  final int maxSize;
  final int maxEntrySize;

  _LruMap({required this.maxSize, required this.maxEntrySize}) {
    assert(maxEntrySize != maxSize);
    assert(maxEntrySize * 5 <= maxSize);
  }

  CacheResponse? operator [](String key) {
    final entry = entries[key];
    if (entry == null) return null;

    _moveToHead(entry);
    return entry.value;
  }

  void operator []=(String key, CacheResponse resp) {
    final entrySize = _computeSize(resp);
    // Entry too heavy, skip it
    if (entrySize > maxEntrySize) return;

    final entry = _Link(key, resp, entrySize);

    entries[key] = entry;
    _currentSize += entry.size;
    _moveToHead(entry);

    while (_currentSize > maxSize) {
      assert(_tail != null);
      remove(_tail!.key);
    }
  }

  void clear() {
    entries.clear();

    _head = null;
    _tail = null;
    _currentSize = 0;
  }

  CacheResponse? remove(String key) {
    final entry = entries[key];
    if (entry == null) return null;

    _currentSize -= entry.size;
    entries.remove(key);

    if (entry == _tail) {
      _tail = entry.next;
      _tail?.previous = null;
    }
    if (entry == _head) {
      _head = entry.previous;
      _head?.next = null;
    }

    return entry.value;
  }

  void _moveToHead(_Link link) {
    if (link == _head) return;

    if (link == _tail) {
      _tail = link.next;
    }

    if (link.previous != null) {
      link.previous!.next = link.next;
    }
    if (link.next != null) {
      link.next!.previous = link.previous;
    }

    _head?.next = link;
    link.previous = _head;
    _head = link;
    _tail ??= link;
    link.next = null;
  }

  int _computeSize(CacheResponse resp) {
    var size = resp.content?.length ?? 0;
    size += resp.headers?.length ?? 0;

    return size;
  }
}

class _Link implements MapEntry<String, CacheResponse> {
  _Link? next;
  _Link? previous;

  final int size;

  @override
  final String key;

  @override
  final CacheResponse value;

  _Link(this.key, this.value, this.size);
}
