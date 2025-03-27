import 'dart:convert';

import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

void main() {
  group('CacheResponse', () {
    late CacheResponse cacheResponse;
    late CacheControl cacheControl;

    setUp(() {
      cacheControl = CacheControl(
        maxAge: 60,
        maxStale: 30,
        mustRevalidate: false,
        minFresh: 10,
      );

      cacheResponse = CacheResponse(
        cacheControl: cacheControl,
        content: utf8.encode('response content'),
        date: DateTime.now(),
        eTag: 'etag_value',
        expires: DateTime.now().add(Duration(minutes: 1)),
        headers: utf8.encode('{"age": "10"}'),
        key: 'cache_key',
        lastModified: 'Wed, 21 Oct 2015 07:28:00 GMT',
        maxStale: null,
        priority: CachePriority.normal,
        requestDate: DateTime.now().subtract(Duration(minutes: 1)),
        responseDate: DateTime.now(),
        url: 'https://example.com',
        statusCode: 200,
      );
    });

    test('isStaled returns false when maxStale is in the future', () {
      expect(cacheResponse.isStaled(), isFalse);
    });

    test('isExpired returns false when response is fresh', () {
      expect(cacheResponse.isExpired(cacheControl), isFalse);
    });

    test('isExpired returns true when response is expired', () {
      cacheResponse = cacheResponse.copyWith(
        headers: utf8.encode('{"age": "100"}'),
      );
      expect(cacheResponse.isExpired(cacheControl), isTrue);
    });

    test('isExpired returns true when response is expired', () {
      final cacheResponse = CacheResponse(
        cacheControl: CacheControl(),
        content: utf8.encode('response content'),
        date: DateTime.now(),
        eTag: 'etag_value',
        expires: null,
        headers: utf8.encode('{"age": "10"}'),
        key: 'cache_key',
        lastModified: 'Wed, 21 Oct 2015 07:28:00 GMT',
        maxStale: null,
        priority: CachePriority.normal,
        requestDate: DateTime.now().subtract(Duration(minutes: 1)),
        responseDate: DateTime.now(),
        url: 'https://example.com',
        statusCode: 200,
      );

      expect(cacheResponse.isExpired(cacheControl), isFalse);
    });

    test('getHeaders returns decoded headers', () {
      final headers = cacheResponse.getHeaders();
      expect(headers['age'], '10');
    });

    test('copyWith creates a new instance with updated values', () {
      final newCacheResponse = cacheResponse.copyWith(eTag: 'new_etag');
      expect(newCacheResponse.eTag, 'new_etag');
      expect(newCacheResponse.cacheControl, cacheResponse.cacheControl);
    });

    test('readContent decrypts content and headers', () async {
      final options = CacheOptions(
        store: MemCacheStore(),
        cipher: CacheCipher(
          decrypt: (bytes) {
            return Future.value(bytes.reversed.toList(growable: false));
          },
          encrypt: (bytes) async {
            return Future.value(bytes.reversed.toList(growable: false));
          },
        ),
      );

      final response = await cacheResponse.readContent(options);
      expect(response.content, utf8.encode('tnetnoc esnopser'));
      expect(response.headers, utf8.encode('}"01" :"ega"{'));
    });

    test('writeContent encrypts content and headers', () async {
      final options = CacheOptions(
        store: MemCacheStore(),
        cipher: CacheCipher(
          decrypt: (bytes) {
            return Future.value(bytes.reversed.toList(growable: false));
          },
          encrypt: (bytes) async {
            return Future.value(bytes.reversed.toList(growable: false));
          },
        ),
      );

      final response = await cacheResponse.writeContent(options);
      expect(response.content, utf8.encode('tnetnoc esnopser'));
      expect(response.headers, utf8.encode('}"01" :"ega"{'));
    });

    test('Equality', () {
      final copy = cacheResponse.copyWith();

      expect(copy, cacheResponse);
    });
  });
}
