// import '../../dio_cache_interceptor.dart';

// /// A store that keeps responses into a simple [Map] in memory.
// ///
// class MemCacheStore extends CacheStore {
//   final _LruMap<String, CacheResponse> _cache;

//   MemCacheStore(int maxSize) : _cache = _LruMap<String, CacheResponse>(maxSize);

//   @override
//   Future<void> clean({
//     CachePriority priorityOrBelow = CachePriority.high,
//     bool stalledOnly = false,
//   }) {
//     for (var i = 0; i <= priorityOrBelow.index; i++) {
//       _cache.remove(CachePriority.values[i]);
//     }
//     return Future.value();
//   }

//   @override
//   Future<void> delete(String key, {bool stalledOnly = false}) {
//     _cache.entries.forEach((entry) {
//       entry.value.removeWhere((x) => x.key == key);
//     });
//     return Future.value();
//   }

//   @override
//   Future<CacheResponse> get(String key) {
//     return Future.value(_cache.entries
//         .expand((x) => x.value)
//         .firstWhere((x) => x.key == key, orElse: () => null));
//   }

//   @override
//   Future<void> set(CacheResponse response) async {
//     await delete(response.key);

//     final withPriority = _cache.putIfAbsent(
//       response.priority,
//       () => <CacheResponse>[],
//     );

//     withPriority.add(response);
//   }
// }

// class _LruMap {
//   _Link<String, CacheResponse> _head;
//   _Link<String, CacheResponse> _tail;

//   int _currentSize = 0;
//   final int maxSize;

//   final entries = <String, _Link<String, CacheResponse>>{};

//   _LruMap(this.maxSize);

//   CacheResponse operator [](String key) {
//     final entry = entries[key];
//     if (entry == null) return null;

//     _promote(entry);
//     return entry.value;
//   }

//   void operator []=(String key, CacheResponse resp) {
//     final entry = _Link(key, resp, _computeSize(resp));

//     entries[key] = entry;
//     _currentSize += entry.size;
//     _promote(entry);

//     while (_currentSize > maxSize) {
//       assert(_tail != null);
//       remove(_tail.key);
//     }
//   }

//   CacheResponse remove(String key) {
//     final entry = entries[key];
//     if (entry == null) return null;

//     _currentSize -= entry.size;
//     entries.remove(key);

//     if (entry == _tail) {
//       _tail = entry.next;
//       _tail?.previous = null;
//     }
//     if (entry == _head) {
//       _head = entry.previous;
//       _head?.next = null;
//     }

//     return entry.value;
//   }

//   /// Moves [link] to the [_head] of the list.
//   void _promote(_Link<String, CacheResponse> link) {
//     if (link == _head) return;

//     if (link == _tail) {
//       _tail = link.next;
//     }

//     if (link.previous != null) {
//       link.previous.next = link.next;
//     }
//     if (link.next != null) {
//       link.next.previous = link.previous;
//     }

//     _head?.next = link;
//     link.previous = _head;
//     _head = link;
//     _tail ??= link;
//     link.next = null;
//   }

//   int _computeSize(CacheResponse resp) {
//     resp.content;
//     return 0;
//   }
// }

// /// A [MapEntry] which is also a part of a doubly linked list.
// class _Link<K, V> implements MapEntry<K, V> {
//   _Link<K, V> next;
//   _Link<K, V> previous;

//   final int size;

//   @override
//   final K key;

//   @override
//   final V value;

//   _Link(this.key, this.value, this.size);
// }