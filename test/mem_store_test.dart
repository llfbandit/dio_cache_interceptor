import 'dart:convert';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor/src/store/mem_cache_store.dart';
import 'package:test/test.dart';

void main() {
  late MemCacheStore store;

  setUp(() async {
    store = MemCacheStore();
    await store.clean();
  });

  tearDown(() async {
    await store.close();
  });

  Future<void> _addFooResponse() {
    final resp = CacheResponse(
      cacheControl: null,
      content: utf8.encode('foo'),
      date: DateTime.now(),
      eTag: 'an etag',
      expires: null,
      headers: null,
      key: 'foo',
      lastModified: null,
      maxStale: null,
      priority: CachePriority.normal,
      responseDate: DateTime.now(),
      url: 'https://foo.com',
    );

    return store.set(resp);
  }

  group('Memory store tests', () {
    test('Empty by default', () async {
      expect(await store.exists('foo'), isFalse);
    });

    test('Add item', () async {
      await _addFooResponse();

      expect(await store.exists('foo'), isTrue);
    });

    test('Get item', () async {
      await _addFooResponse();

      final resp = await store.get('foo');
      expect(resp, isNotNull);
      expect(resp?.key, 'foo');
      expect(resp?.url, 'https://foo.com');
      expect(resp?.eTag, 'an etag');
      expect(resp?.lastModified, isNull);
      expect(resp?.maxStale, isNull);
      expect(resp?.content, utf8.encode('foo'));
      expect(resp?.headers, isNull);
      expect(resp?.priority, CachePriority.normal);
    });

    test('Delete item', () async {
      await _addFooResponse();
      expect(await store.exists('foo'), isTrue);

      await store.delete('foo');
      expect(await store.exists('foo'), isFalse);
    });
  });
}
