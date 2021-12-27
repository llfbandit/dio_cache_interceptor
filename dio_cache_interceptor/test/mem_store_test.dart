import 'dart:io';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:test/test.dart';

import 'common_store_testing.dart';

void main() {
  late MemCacheStore store;

  setUp(() async {
    store = MemCacheStore(maxEntrySize: 100000, maxSize: 500000);
    await store.clean();
  });

  tearDown(() async {
    await store.close();
  });

  test('Exceeds maxSize', () async {
    final now = DateTime.now();
    final content = File('./README.md').readAsBytesSync();

    for (var i = 0; i < 150; ++i) {
      final resp = CacheResponse(
        cacheControl: null,
        content: content,
        date: now,
        eTag: 'an etag',
        expires: null,
        headers: null,
        key: 'foo_$i',
        lastModified: null,
        maxStale: null,
        priority: CachePriority.normal,
        responseDate: now,
        url: 'https://foo.com',
      );

      await store.set(resp);
    }

    var validEntries = 0;
    var recycledEntries = 0;
    for (var i = 0; i < 150; ++i) {
      final resp = await store.get('foo_$i');
      validEntries = resp != null ? validEntries + 1 : validEntries;
      recycledEntries = resp == null ? recycledEntries + 1 : recycledEntries;
    }

    expect(validEntries, greaterThan(0), reason: 'validEntries');
    expect(recycledEntries, greaterThan(0), reason: 'recycledEntries');
  });

  test('Empty by default', () async => await emptyByDefault(store));
  test('Add item', () async => await addItem(store));
  test('Get item', () async => await getItem(store));
  test('Delete item', () async => await deleteItem(store));
  test('Clean', () async => await clean(store));
  test('Expires', () async => await expires(store));
  test('LastModified', () async => await lastModified(store));
}
