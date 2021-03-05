import 'dart:convert';

import 'package:dio_cache_interceptor/src/model/cache_priority.dart';
import 'package:dio_cache_interceptor/src/model/cache_response.dart';
import 'package:dio_cache_interceptor/src/store/cache_store.dart';
import 'package:test/test.dart';

Future<void> _addFooResponse(CacheStore store) {
  final resp = CacheResponse(
    cacheControl: null,
    content: utf8.encode('foo'),
    date: DateTime.now(),
    eTag: 'an etag',
    expires: null,
    headers: null,
    key: 'foo',
    lastModified: null,
    maxStale: DateTime.now().add(const Duration(days: 1)),
    priority: CachePriority.normal,
    responseDate: DateTime.now(),
    url: 'https://foo.com',
  );

  return store.set(resp);
}

Future<void> emptyByDefault(CacheStore store) async {
  expect(await store.exists('foo'), isFalse);
}

Future<void> addItem(CacheStore store) async {
  await _addFooResponse(store);
  expect(await store.exists('foo'), isTrue);
}

Future<void> getItem(CacheStore store) async {
  await _addFooResponse(store);

  final resp = await store.get('foo');
  expect(resp, isNotNull);
  expect(resp?.key, 'foo');
  expect(resp?.url, 'https://foo.com');
  expect(resp?.eTag, 'an etag');
  expect(resp?.lastModified, isNull);
  expect(resp?.maxStale, isNotNull);
  expect(resp?.content, utf8.encode('foo'));
  expect(resp?.headers, isNull);
  expect(resp?.priority, CachePriority.normal);
}

Future<void> deleteItem(CacheStore store) async {
  await _addFooResponse(store);
  expect(await store.exists('foo'), isTrue);

  await store.delete('foo');
  expect(await store.exists('foo'), isFalse);
}

Future<void> clean(CacheStore store) async {
  await _addFooResponse(store);
  expect(await store.exists('foo'), isTrue);

  await store.clean(staleOnly: true);
  expect(await store.exists('foo'), isTrue);

  await store.clean(priorityOrBelow: CachePriority.low);
  expect(await store.exists('foo'), isTrue);

  await store.clean();
  expect(await store.exists('foo'), isFalse);
}
