import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/model/cache_control.dart';
import 'package:dio_cache_interceptor/src/model/cache_priority.dart';
import 'package:dio_cache_interceptor/src/model/cache_response.dart';
import 'package:dio_cache_interceptor/src/store/cache_store.dart';
import 'package:test/test.dart';

Future<void> _addFooResponse(
  CacheStore store, {
  CacheControl? cacheControl,
  DateTime? expires,
  String? lastModified,
  List<int>? headers,
  DateTime? maxStale,
}) {
  final resp = CacheResponse(
    cacheControl: cacheControl,
    content: utf8.encode('foo'),
    date: DateTime.now(),
    eTag: 'an etag',
    expires: expires,
    headers: headers,
    key: 'foo',
    lastModified: lastModified,
    maxStale: maxStale,
    priority: CachePriority.normal,
    responseDate: DateTime.now(),
    url: 'https://foo.com',
  );

  return store.set(resp);
}

Future<void> emptyByDefault(CacheStore store) async {
  expect(await store.exists('foo'), isFalse);
  expect(await store.get('foo'), isNull);
}

Future<void> addItem(CacheStore store) async {
  await _addFooResponse(store);
  expect(await store.exists('foo'), isTrue);
}

Future<void> getItem(CacheStore store) async {
  final headers = utf8.encode(
    jsonEncode({
      Headers.contentTypeHeader: [Headers.jsonContentType]
    }),
  );
  final cacheControl = CacheControl(maxAge: 10, privacy: 'public');

  await _addFooResponse(
    store,
    maxStale: DateTime.now().add(const Duration(days: 1)),
    headers: headers,
    cacheControl: cacheControl,
  );

  final resp = await store.get('foo');
  expect(resp, isNotNull);
  expect(resp?.key, equals('foo'));
  expect(resp?.url, equals('https://foo.com'));
  expect(resp?.eTag, equals('an etag'));
  expect(resp?.lastModified, isNull);
  expect(resp?.maxStale, isNotNull);
  expect(resp?.content, equals(utf8.encode('foo')));
  expect(resp?.headers, equals(headers));
  expect(resp?.priority, CachePriority.normal);
  expect(resp?.cacheControl?.maxAge, equals(cacheControl.maxAge));
  expect(resp?.cacheControl?.privacy, equals(cacheControl.privacy));
}

Future<void> deleteItem(CacheStore store) async {
  await _addFooResponse(store);
  expect(await store.exists('foo'), isTrue);

  await store.delete('foo');
  expect(await store.exists('foo'), isFalse);
  await store.delete('foo'); // check for non exception

  await _addFooResponse(
    store,
    maxStale: DateTime.now().add(const Duration(days: 1)),
  );
  expect(await store.exists('foo'), isTrue);

  await store.delete('foo', staleOnly: true);
  expect(await store.exists('foo'), isTrue);
}

Future<void> clean(CacheStore store) async {
  await _addFooResponse(
    store,
    maxStale: DateTime.now().add(const Duration(days: 1)),
  );
  expect(await store.exists('foo'), isTrue);

  await store.clean(staleOnly: true);
  expect(await store.exists('foo'), isTrue);

  await store.clean(priorityOrBelow: CachePriority.low);
  expect(await store.exists('foo'), isTrue);

  await store.clean();
  expect(await store.exists('foo'), isFalse);
}

Future<void> staled(CacheStore store) async {
  await _addFooResponse(
    store,
    maxStale: DateTime.now().subtract(const Duration(seconds: 1)),
  );
  expect(await store.exists('foo'), isTrue);

  final resp = await store.get('foo');
  expect(resp, isNull);
}

Future<void> expires(CacheStore store) async {
  final now = DateTime.now();
  await _addFooResponse(store, expires: DateTime.now());
  final resp = await store.get('foo');
  expect(
    resp!.expires!.subtract(
      Duration(
          milliseconds: resp.expires!.millisecond,
          microseconds: resp.expires!.microsecond),
    ),
    equals(
      now.subtract(
        Duration(milliseconds: now.millisecond, microseconds: now.microsecond),
      ),
    ),
  );
}

Future<void> lastModified(CacheStore store) async {
  final lastModified = 'Wed, 21 Oct 2015 07:28:00 GMT';

  await _addFooResponse(store, lastModified: lastModified);
  final resp = await store.get('foo');
  expect(resp!.lastModified, equals(lastModified));
}
