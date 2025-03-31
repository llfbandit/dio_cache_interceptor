import 'dart:convert';

import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

void main() {
  group('CacheResponse', () {
    late CacheResponse cacheResponse;

    setUp(() {
      cacheResponse = CacheResponse(
        cacheControl: CacheControl(),
        content: utf8.encode('response content'),
        date: null,
        eTag: null,
        expires: null,
        headers: null,
        key: 'cache_key',
        lastModified: null,
        maxStale: null,
        priority: CachePriority.normal,
        requestDate: DateTime.now().subtract(Duration(seconds: 2)),
        responseDate: DateTime.now(),
        url: 'https://example.com',
        statusCode: 200,
      );
    });

    test('isStaled returns false when no maxStale is set', () {
      expect(cacheResponse.isStaled(), isFalse);
    });

    test('isStaled returns false when maxStale is in the future', () {
      cacheResponse = cacheResponse.copyWith(
        maxStale: DateTime.now().add(Duration(minutes: 1)),
      );
      expect(cacheResponse.isStaled(), isFalse);
    });

    test('isStaled returns true when maxStale is in the past', () {
      cacheResponse = cacheResponse.copyWith(
        maxStale: DateTime.now().subtract(Duration(minutes: 1)),
      );
      expect(cacheResponse.isStaled(), isTrue);
    });

    test('isExpired returns true when response has no expiration time', () {
      expect(cacheResponse.isExpired(CacheControl()), isTrue);
    });

    test(
        'isExpired returns true when response is expired - max-age (w/ request date)',
        () {
      cacheResponse = cacheResponse.copyWith(
        requestDate: DateTime.now().subtract(Duration(seconds: 2)),
        cacheControl: CacheControl(maxAge: 1),
      );
      expect(cacheResponse.isExpired(CacheControl()), isTrue);
    });

    test(
        'isExpired returns true when response is expired - max-age (w/ date header)',
        () {
      cacheResponse = cacheResponse.copyWith(
        date: DateTime.now().subtract(const Duration(seconds: 2)),
        cacheControl: CacheControl(maxAge: 1),
      );
      expect(cacheResponse.isExpired(CacheControl()), isTrue);
    });

    test(
        'isExpired returns true when response is expired - max-age from request',
        () {
      cacheResponse = cacheResponse.copyWith(
        date: DateTime.now().subtract(const Duration(seconds: 2)),
      );
      expect(cacheResponse.isExpired(CacheControl(maxAge: 1)), isTrue);
    });

    test(
        'isExpired returns false when response is fresh - max-age from request',
        () {
      cacheResponse = cacheResponse.copyWith(
        date: DateTime.now().subtract(const Duration(seconds: 2)),
        cacheControl: CacheControl(maxAge: 5),
      );
      expect(cacheResponse.isExpired(CacheControl(maxAge: 6)), isFalse);
    });

    test(
        'isExpired returns false when response is fresh - max-stale from request',
        () {
      cacheResponse = cacheResponse.copyWith(
        date: DateTime.now().subtract(const Duration(seconds: 2)),
        cacheControl: CacheControl(maxAge: 2),
      );
      expect(cacheResponse.isExpired(CacheControl(maxStale: 3)), isFalse);
    });

    test('isExpired returns true when response is expired - expires', () {
      cacheResponse = cacheResponse.copyWith(
        cacheControl: CacheControl(),
        expires: DateTime.now().subtract(Duration(minutes: 2)),
      );

      expect(cacheResponse.isExpired(CacheControl()), isTrue);
    });

    test('isExpired returns false when response is fresh - expires', () {
      cacheResponse = cacheResponse.copyWith(
        cacheControl: CacheControl(),
        expires: DateTime.now().add(Duration(minutes: 2)),
      );

      expect(cacheResponse.isExpired(CacheControl()), isFalse);
    });

    test(
        'isExpired returns true when response is expired - max-age precedence on expires',
        () {
      cacheResponse = cacheResponse.copyWith(
        cacheControl: CacheControl(maxAge: 1),
        expires: DateTime.now().add(Duration(minutes: 2)),
      );

      expect(cacheResponse.isExpired(CacheControl()), isTrue);
    });

    test('isExpired returns true when response is expired - lastModified', () {
      cacheResponse = cacheResponse.copyWith(
        requestDate: DateTime.now().subtract(Duration(seconds: 1)),
        cacheControl: CacheControl(),
        lastModified: HttpDate.format(
            DateTime.now().subtract(Duration(seconds: 2))), // 10% => 0.2
      );

      expect(cacheResponse.isExpired(CacheControl()), isTrue);
    });

    test('isExpired returns false when response is fresh - lastModified', () {
      cacheResponse = cacheResponse.copyWith(
        requestDate: DateTime.now().subtract(Duration(seconds: 1)),
        cacheControl: CacheControl(),
        lastModified: HttpDate.format(DateTime.now()
            .subtract(Duration(seconds: 19))), // 10% => 1.9 rounded to 2
      );

      expect(cacheResponse.isExpired(CacheControl()), isFalse);
    });

    test('getHeaders returns decoded headers', () {
      cacheResponse = cacheResponse.copyWith(
        headers: utf8.encode('{"age": "10"}'),
      );

      final headers = cacheResponse.getHeaders();
      expect(headers['age'], '10');
    });

    test('copyWith creates a new instance with updated values', () {
      final newCacheResponse = cacheResponse.copyWith(eTag: 'new_etag');

      expect(newCacheResponse.eTag, 'new_etag');
      expect(newCacheResponse, isNot(equals(cacheResponse)));
      expect(newCacheResponse.cacheControl, cacheResponse.cacheControl);
    });

    test('readContent decrypts content and headers', () async {
      cacheResponse = cacheResponse.copyWith(
        headers: utf8.encode('{"age": "10"}'),
      );

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

      var response = await cacheResponse.readContent(options,
          readHeaders: true, readBody: false);
      expect(response.headers, utf8.encode('}"01" :"ega"{'));
      expect(response.content, utf8.encode('response content'));

      response = await cacheResponse.readContent(options,
          readHeaders: false, readBody: true);
      expect(response.headers, utf8.encode('{"age": "10"}'));
      expect(response.content, utf8.encode('tnetnoc esnopser'));
    });

    test('writeContent encrypts content and headers', () async {
      cacheResponse = cacheResponse.copyWith(
        headers: utf8.encode('{"age": "10"}'),
      );

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
