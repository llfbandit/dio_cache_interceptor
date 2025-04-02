import 'dart:convert';

import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

class MockRequest extends BaseRequest {
  final Uri url;

  MockRequest({required this.url, Map<String, String>? headers})
      : headers = headers ?? {};

  @override
  final Map<String, String> headers;

  @override
  void setHeader(String header, String? value) {
    if (value == null) {
      headers.remove(header);
    } else {
      headers[header] = value;
    }
  }
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
    Map<String, List<String>>? headers,
    this.attachment = false,
  }) : headers = headers ?? {};

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
      expect(strategy.request!.headers[ifNoneMatchHeader], isNotNull);
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
      expect(strategy.request!.headers[ifModifiedSinceHeader], isNotNull);
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
      expect(strategy.request!.headers[ifModifiedSinceHeader], isNotNull);
    });

    Future<BaseRequest> testWithPreconditionRequest(
      Map<String, String> headers, {
      String? eTag,
      DateTime? lastModified,
      DateTime? date,
    }) async {
      final request = MockRequest(
        url: Uri.parse('https://ok.org'),
        headers: headers,
      );
      final response = MockResponse(
        statusCode: 200,
        eTag: eTag,
        lastModified: lastModified,
        date: date,
      );
      final cacheResponse = cacheResponsefrom(cacheOptions, request, response);

      final strategy = CacheStrategyFactory(
        request: request,
        cacheOptions: cacheOptions,
        response: response,
        cacheResponse: cacheResponse,
      );

      final result = await strategy.compute();

      expect(result.request, isNotNull);
      expect(result.cacheResponse, isNull);

      return result.request!;
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

    test(
        'compute returns request from preconditions - ifNoneMatch takes precedence on ifModifiedSince',
        () async {
      final request = await testWithPreconditionRequest(
        {
          ifNoneMatchHeader: '123',
          ifModifiedSinceHeader: HttpDate.format(DateTime.now())
        },
      );

      expect(request.headers[ifNoneMatchHeader], isNotNull);
      expect(request.headers[ifModifiedSinceHeader], isNull);
    });

    test(
        'compute returns request - ifNoneMatch takes precedence on ifModifiedSince',
        () async {
      final request = await testWithPreconditionRequest(
        {},
        eTag: '123',
        lastModified: DateTime.now().subtract(Duration(seconds: 10)),
        date: DateTime.now().subtract(Duration(seconds: 5)),
      );

      expect(request.headers[ifNoneMatchHeader], isNotNull);
      expect(request.headers[ifModifiedSinceHeader], isNull);
    });

    test(
        'compute returns request - ifNoneMatch takes precedence on ifModifiedSince',
        () async {
      final lastModified = DateTime.now().subtract(Duration(seconds: 10));

      final request = await testWithPreconditionRequest(
        {},
        lastModified: lastModified,
        date: DateTime.now().subtract(Duration(seconds: 5)),
      );

      expect(request.headers[ifNoneMatchHeader], isNull);
      expect(request.headers[ifModifiedSinceHeader], isNotNull);
    });
  });
}
