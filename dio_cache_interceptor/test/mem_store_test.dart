import 'dart:typed_data';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:test/test.dart';

import 'common_store_testing.dart';

void main() {
  late MemCacheStore store;

  setUp(() {
    store = MemCacheStore(maxEntrySize: 100000, maxSize: 500000);
  });

  tearDown(() async {
    await store.close();
  });

  Future<void> storeResponse(
    String key,
    List<int> content,
    List<int>? headers,
  ) {
    final now = DateTime.now();

    return store.set(CacheResponse(
      cacheControl: CacheControl(),
      content: content,
      date: now,
      eTag: 'etag/$key',
      expires: null,
      headers: headers,
      key: key,
      lastModified: null,
      maxStale: null,
      priority: CachePriority.normal,
      requestDate: now.subtract(const Duration(milliseconds: 50)),
      responseDate: now,
      url: 'https://foo.com',
    ));
  }

  test('Exceeds maxSize', () async {
    final content = Uint8List(100000);

    for (var i = 0; i < 50; ++i) {
      await storeResponse('foo_$i', content, null);
    }

    var valid = <String>[];
    var recycled = <String>[];
    for (var i = 0; i < 50; ++i) {
      final resp = await store.get('foo_$i');
      if (resp != null) {
        valid.add('foo_$i');
      } else {
        recycled.add('foo_$i');
      }
    }

    expect(valid.length, equals(5), reason: 'valid entries length');
    expect(valid.first, equals('foo_45'), reason: 'valid entries first');
    expect(valid.last, equals('foo_49'), reason: 'valid entries last');

    expect(recycled.length, equals(45), reason: 'recycled entries length');
    expect(recycled.first, equals('foo_0'), reason: 'recycled entries first');
    expect(recycled.last, equals('foo_44'), reason: 'recycled entries last');
  });

  test('maxEntrySize at max', () async {
    await storeResponse('foo1', Uint8List(100000), null);
    expect(await store.exists('foo1'), isTrue);

    await storeResponse('foo2', Uint8List(99998), Uint8List(2));
    expect(await store.exists('foo2'), isTrue);
  });

  test('maxEntrySize above max', () async {
    await storeResponse('foo1', Uint8List(100001), null);
    expect(await store.exists('foo1'), isFalse);

    await storeResponse('foo2', Uint8List(99998), Uint8List(3));
    expect(await store.exists('foo2'), isFalse);
  });

  test('Empty by default', () async => await emptyByDefault(store));
  test('Add item', () async => await addItem(store));
  test('Get item', () async => await getItem(store));
  test('Delete item', () async => await deleteItem(store));
  test('Clean', () async => await clean(store));
  test('Expires', () async => await expires(store));
  test('LastModified', () async => await lastModified(store));
  test('pathExists', () => pathExists(store));
  test('deleteFromPath', () => deleteFromPath(store));
  test('getFromPath', () => getFromPath(store));
}
