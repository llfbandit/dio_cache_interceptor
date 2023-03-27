import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/model/cache_control.dart';
import 'package:dio_cache_interceptor/src/model/cache_priority.dart';
import 'package:dio_cache_interceptor/src/model/cache_response.dart';
import 'package:dio_cache_interceptor/src/store/cache_store.dart';
import 'package:test/test.dart';

Future<void> _addFooResponse(
  CacheStore store, {
  String key = 'foo',
  CacheControl? cacheControl,
  DateTime? expires,
  String? lastModified,
  List<int>? headers,
  DateTime? maxStale,
  String url = 'https://foo.com',
}) {
  final resp = CacheResponse(
    cacheControl: cacheControl ?? CacheControl(),
    content: utf8.encode('foo'),
    date: DateTime.now(),
    eTag: 'an, etag',
    expires: expires,
    headers: headers,
    key: key,
    lastModified: lastModified,
    maxStale: maxStale,
    priority: CachePriority.normal,
    requestDate: DateTime.now().subtract(const Duration(milliseconds: 50)),
    responseDate: DateTime.now(),
    url: url,
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
  expect(resp?.eTag, equals('an, etag'));
  expect(resp?.lastModified, isNull);
  expect(resp?.maxStale, isNotNull);
  expect(resp?.content, equals(utf8.encode('foo')));
  expect(resp?.headers, equals(headers));
  expect(resp?.priority, CachePriority.normal);
  expect(resp?.cacheControl.maxAge, equals(cacheControl.maxAge));
  expect(resp?.cacheControl.privacy, equals(cacheControl.privacy));
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

Future<void> concurrentAccess(CacheStore store) async {
  final lastModified = 'Wed, 21 Oct 2015 07:28:00 GMT';

  final completer = Completer();
  final max = 3000;

  for (var i = 1; i <= max; i++) {
    final key = i % 3 == 0 ? 'bar' : 'foo';
    _addFooResponse(store, key: key, lastModified: lastModified).then(
      (value) {
        store.get(key).then(
          (resp) {
            if (i % 3 == 0) {
              store.exists(key).then((value) {
                if (i == max) completer.complete();
              });
            } else if (i % 4 == 0) {
              store.clean().then((value) {
                if (i == max) completer.complete();
              });
            } else if (i % 5 == 0) {
              store.delete(key).then((value) {
                if (i == max) completer.complete();
              });
            } else {
              if (i == max) completer.complete();
            }
          },
        );
      },
    );
  }

  await completer.future;
}

void pathExists(CacheStore store) {
  // Match regex with no query params
  expect(store.pathExists('/foo', RegExp('/foo')), isTrue);
  expect(store.pathExists('/foo', RegExp('/bar')), isFalse);

  // Match with null query params (matches all query params)
  expect(
    store.pathExists(
      Uri(
        path: '/foo',
        queryParameters: {'bar': 'foobar'},
      ).toString(),
      RegExp('/foo'),
      queryParams: null,
    ),
    isTrue,
  );

  // Match with null value query param (matches key with any value)
  expect(
    store.pathExists(
      Uri(
        path: '/foo',
        queryParameters: {'bar': 'foobar'},
      ).toString(),
      RegExp('/foo'),
      queryParams: {'bar': null},
    ),
    isTrue,
  );

  // Match with exact query params
  expect(
    store.pathExists(
      Uri(
        path: '/foo',
        queryParameters: {'bar': 'foobar'},
      ).toString(),
      RegExp('/foo'),
      queryParams: {'bar': 'foobar'},
    ),
    isTrue,
  );

  // No match on different query param value
  expect(
    store.pathExists(
      Uri(
        path: '/foo',
        queryParameters: {'bar': 'foobar'},
      ).toString(),
      RegExp('/foo'),
      queryParams: {'bar': 'baz'},
    ),
    isFalse,
  );

  // No match on query params with different values
  expect(
    store.pathExists(
      Uri(
        path: '/foo',
        queryParameters: {
          'bar': 'foo',
          'qux': 'bar',
        },
      ).toString(),
      RegExp('/foo'),
      queryParams: {
        'bar': 'foo',
        'qux': 'foo',
      },
    ),
    isFalse,
  );
}

Future<void> deleteFromPath(CacheStore store) async {
  await _addFooResponse(store);
  expect(await store.exists('foo'), isTrue);
  await store.deleteFromPath(RegExp('https://foo.com'));
  expect(await store.exists('foo'), isFalse);

  await _addFooResponse(store, url: 'https://foo.com?bar=bar');
  expect(await store.exists('foo'), isTrue);
  await store.deleteFromPath(
    RegExp('https://foo.com'),
    queryParams: {'bar': null},
  );
  expect(await store.exists('foo'), isFalse);

  await _addFooResponse(store, url: 'https://foo.com?bar=bar');
  expect(await store.exists('foo'), isTrue);
  await store.deleteFromPath(
    RegExp('https://foo.com'),
    queryParams: {'bar': 'bar'},
  );
  expect(await store.exists('foo'), isFalse);

  await _addFooResponse(store, url: 'https://foo.com?bar=bar');
  expect(await store.exists('foo'), isTrue);
  await store.deleteFromPath(
    RegExp('https://foo.com'),
    queryParams: {'bar': 'foobar'},
  );
  expect(await store.exists('foo'), isTrue);
}

Future<void> getFromPath(CacheStore store) async {
  await _addFooResponse(store);
  var list = await store.getFromPath(RegExp('https://foo.com'));
  expect(list.length, 1);

  await _addFooResponse(store, url: 'https://foo.com?bar=bar');
  list = await store.getFromPath(
    RegExp('https://foo.com'),
    queryParams: {'bar': null},
  );
  expect(list.length, 1);

  await _addFooResponse(store, url: 'https://foo.com?bar=bar');
  list = await store.getFromPath(
    RegExp('https://foo.com'),
    queryParams: {'bar': 'bar'},
  );
  expect(list.length, 1);

  await _addFooResponse(store, url: 'https://foo.com?bar=bar');
  list = await store.getFromPath(
    RegExp('https://foo.com'),
    queryParams: {'bar': 'foobar'},
  );
  expect(list.length, 0);
}
