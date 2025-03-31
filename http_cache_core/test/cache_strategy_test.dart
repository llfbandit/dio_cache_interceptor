import 'dart:convert';

import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

class MockRequest extends BaseRequest {
  final Uri url;
  final Map<String, String> _headers;

  MockRequest({required this.url, Map<String, String> headers = const {}})
      : _headers = Map.of(headers);

  @override
  List<String>? headerValuesAsList(String header) {
    final value = _headers[header.toLowerCase()];

    if (value != null) {
      final values = <String>[];

      if (!value.contains(',')) {
        values.add(value);
      } else {
        if (header == 'set-cookie') {
          return value.split(setCookieSplitter);
        } else {
          return value.split(headerSplitter);
        }
      }

      return values;
    }

    return null;
  }

  @override
  void setHeader(String header, String? value) {
    if (value == null) {
      _headers.remove(header);
    } else {
      _headers[header] = value;
    }
  }

  Map<String, String> get headers => _headers;
}

class MockResponse extends BaseResponse {
  final String? eTag;
  final DateTime? lastModified;
  final DateTime? date;
  final bool attachment;

  MockResponse({
    required this.statusCode,
    this.eTag,
    this.lastModified,
    this.date,
    this.headers = const {},
    this.attachment = false,
  });

  @override
  final int statusCode;

  @override
  final Map<String, List<String>> headers;

  @override
  bool isAttachment() => attachment;

  @override
  Uri get requestUri => throw UnimplementedError();
}

void main() {
  CacheResponse cacheResponsefrom(
      CacheOptions cacheOptions, MockRequest request, MockResponse response) {
    return CacheResponse(
      key: cacheOptions.keyBuilder(
        url: request.url,
        headers: request.headers,
      ),
      cacheControl: CacheControl.fromHeader(
        response.headers[cacheControlHeader],
      ),
      content: null,
      date: response.date,
      eTag: response.eTag,
      expires: null,
      lastModified: response.lastModified != null
          ? HttpDate.format(response.lastModified!)
          : null,
      maxStale: null,
      priority: CachePriority.normal,
      requestDate: DateTime.now(),
      responseDate: DateTime.now(),
      url: request.url.toString(),
      statusCode: response.statusCode,
      headers: utf8.encode(jsonEncode(response.headers)),
    );
  }

  group('CacheStrategyFactory', () {
    late CacheOptions cacheOptions;

    setUp(() {
      cacheOptions = CacheOptions(store: MemCacheStore());
    });

    test('compute returns cached response when cache is valid', () async {
      final request = MockRequest(
        url: Uri.parse('https://ok.org'),
        headers: {etagHeader: '1234'},
      );
      // Set up the response to be cacheable
      final response = MockResponse(statusCode: 200, headers: {
        'cache-control': ['public, max-age=3600'],
        etagHeader: ['1234'],
      });
      final cacheResponse = cacheResponsefrom(cacheOptions, request, response);

      final factory = CacheStrategyFactory(
        request: request,
        cacheOptions: cacheOptions,
        response: response,
        cacheResponse: cacheResponse,
      );

      final strategy = await factory.compute();

      expect(strategy.request, isNull);
      expect(strategy.cacheResponse, equals(cacheResponse));
    });

    test('compute returns request when cache is expired', () async {
      final request = MockRequest(url: Uri.parse('https://ok.org'));
      // Set up the response to be cacheable but expired
      final response = MockResponse(statusCode: 200, headers: {
        'cache-control': ['public, max-age=0'],
      });

      final cacheResponse = cacheResponsefrom(cacheOptions, request, response);

      await Future.delayed(Duration(seconds: 1));

      final factory = CacheStrategyFactory(
        request: request,
        cacheOptions: cacheOptions,
        response: response,
        cacheResponse: cacheResponse,
      );

      final strategy = await factory.compute();

      expect(strategy.request, isNotNull);
      expect(strategy.cacheResponse, isNull);
    });

    test('compute returns cached response when forceCache policy is set',
        () async {
      final request = MockRequest(url: Uri.parse('https://ok.org'));
      // Set up the response to be cacheable
      final response = MockResponse(statusCode: 200, headers: {
        'cache-control': ['public, max-age=3600'],
      });
      cacheOptions = cacheOptions.copyWith(policy: CachePolicy.forceCache);
      final cacheResponse = cacheResponsefrom(cacheOptions, request, response);

      final factory = CacheStrategyFactory(
        request: request,
        cacheOptions: cacheOptions,
        response: response,
        cacheResponse: cacheResponse,
      );

      final strategy = await factory.compute();

      expect(strategy.request, isNull);
      expect(strategy.cacheResponse, isNotNull);
      expect(strategy.cacheResponse, equals(cacheResponse));
    });

    test('compute returns cached response when valid', () async {
      final request = MockRequest(url: Uri.parse('https://ok.org'));
      // Set up the response to be cacheable
      final response = MockResponse(statusCode: 200, headers: {
        'cache-control': ['public, max-age=3600'],
      });

      final factory = CacheStrategyFactory(
        request: request,
        cacheOptions: cacheOptions,
        response: response,
      );

      final strategy = await factory.compute(
          cacheResponseBuilder: () async =>
              cacheResponsefrom(cacheOptions, request, response));

      expect(strategy.request, isNull);
      expect(strategy.cacheResponse, isNotNull);
    });

    test(
        'compute returns request when no cache response and cache is not valid',
        () async {
      final request = MockRequest(url: Uri.parse('https://ok.org'));
      // Set up the response to be non-cacheable
      final response = MockResponse(statusCode: 200, headers: {
        'cache-control': ['no-store'],
      });
      final cacheResponse = cacheResponsefrom(cacheOptions, request, response);

      final factory = CacheStrategyFactory(
        request: request,
        cacheOptions: cacheOptions,
        response: response,
        cacheResponse: cacheResponse,
      );

      final strategy = await factory.compute();

      expect(strategy.request, isNotNull);
      expect(strategy.cacheResponse, isNull);
    });

    test('compute returns conditional request on etag', () async {
      final request = MockRequest(url: Uri.parse('https://ok.org'));
      // Set up the response to be non-cacheable
      final response = MockResponse(statusCode: 200, eTag: '1324');
      final cacheResponse = cacheResponsefrom(cacheOptions, request, response);

      final factory = CacheStrategyFactory(
        request: request,
        cacheOptions: cacheOptions,
        response: response,
        cacheResponse: cacheResponse,
      );

      final strategy = await factory.compute();

      expect(strategy.request, isNotNull);
      expect(strategy.cacheResponse, isNull);
      expect(
          strategy.request!.headerValuesAsList(ifNoneMatchHeader), isNotNull);
    });

    test('compute returns conditional request on lastModified', () async {
      final request = MockRequest(url: Uri.parse('https://ok.org'));
      // Set up the response to be non-cacheable
      final response = MockResponse(
        statusCode: 200,
        lastModified: DateTime.now(),
        headers: {
          'cache-control': ['no-cache']
        },
      );
      final cacheResponse = cacheResponsefrom(cacheOptions, request, response);

      final factory = CacheStrategyFactory(
        request: request,
        cacheOptions: cacheOptions,
        response: response,
        cacheResponse: cacheResponse,
      );

      final strategy = await factory.compute();

      expect(strategy.request, isNotNull);
      expect(strategy.cacheResponse, isNull);
      expect(strategy.request!.headerValuesAsList(ifModifiedSinceHeader),
          isNotNull);
    });

    test('compute returns conditional request on date', () async {
      final request = MockRequest(url: Uri.parse('https://ok.org'));
      // Set up the response to be non-cacheable
      final response = MockResponse(
        statusCode: 200,
        date: DateTime.now(),
        headers: {
          'cache-control': ['no-cache']
        },
      );
      final cacheResponse = cacheResponsefrom(cacheOptions, request, response);

      final factory = CacheStrategyFactory(
        request: request,
        cacheOptions: cacheOptions,
        response: response,
        cacheResponse: cacheResponse,
      );

      final strategy = await factory.compute();

      expect(strategy.request, isNotNull);
      expect(strategy.cacheResponse, isNull);
      expect(strategy.request!.headerValuesAsList(ifModifiedSinceHeader),
          isNotNull);
    });

    Future<void> testWithPreconditionRequest(
        Map<String, String> headers) async {
      final request = MockRequest(
        url: Uri.parse('https://ok.org'),
        headers: {cacheControlHeader: 'no-cache'},
      );
      final response = MockResponse(statusCode: 200);
      final cacheResponse = cacheResponsefrom(cacheOptions, request, response);

      final factory = CacheStrategyFactory(
        request: request,
        cacheOptions: cacheOptions,
        response: response,
        cacheResponse: cacheResponse,
      );

      final strategy = await factory.compute();

      expect(strategy.request, isNotNull);
      expect(strategy.cacheResponse, isNull);
    }

    test('compute returns request from preconditions - no-cache', () async {
      testWithPreconditionRequest({cacheControlHeader: 'no-cache'});
    });

    test('compute returns request from preconditions - ifModifiedSince',
        () async {
      await testWithPreconditionRequest(
        {ifModifiedSinceHeader: HttpDate.format(DateTime.now())},
      );
    });

    test('compute returns request from preconditions - ifNoneMatch', () async {
      await testWithPreconditionRequest({ifNoneMatchHeader: '123'});
    });

    test(
        'compute returns request from preconditions - ifModifiedSince && no-cache',
        () async {
      await testWithPreconditionRequest(
        {
          ifModifiedSinceHeader: HttpDate.format(DateTime.now()),
          cacheControlHeader: 'no-cache'
        },
      );
    });
  });
}
