import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:http_cache_client/http_cache_client.dart';
import 'package:http_cache_core/http_cache_core.dart';

Future<http.Response> getOk(
  CacheOptions options, {
  Map<String, String>? headers,
}) {
  final url = Uri.http('ok.org', '/ok');

  var client = CacheClient(
    MockClient(
      (request) async => http.Response(
        jsonEncode({'path': request.url.path}),
        request.headers.containsKey('x-err') ? 500 : 200,
        headers: {
          contentTypeHeader: jsonContentType,
          etagHeader: '1234',
          dateHeader: HttpDate.format(DateTime.now()),
        },
        request: request,
      ),
    ),
    options: options,
  );

  return client.get(url, options: options, headers: headers);
}

Future<http.Response> download(CacheOptions options) {
  final url = Uri.http('ok.org', '/ok');

  var client = CacheClient(
    MockClient(
      (request) async => http.Response(
        jsonEncode({'path': request.url.path}),
        200,
        headers: {
          contentTypeHeader: jsonContentType,
          'Content-Disposition': 'attachment; filename="filename.jpg"',
          dateHeader: HttpDate.format(DateTime.now()),
        },
        request: request,
      ),
    ),
    options: options,
  );

  return client.get(url, options: options);
}

Future<http.Response> postOk(CacheOptions options) {
  final url = Uri.http('ok.org', '/ok');

  var client = CacheClient(
    MockClient(
      (request) async => http.Response(
        jsonEncode({'path': request.url.path}),
        200,
        headers: {
          contentTypeHeader: jsonContentType,
          etagHeader: '1234',
          dateHeader: HttpDate.format(DateTime.now()),
        },
        request: request,
      ),
    ),
    options: options,
  );

  return client.post(url, options: options);
}

Future<http.Response> cacheControl(CacheOptions options) {
  final url = Uri.http('ok.org', '/cache-control');

  var client = CacheClient(
    MockClient(
      (request) async => http.Response(
        jsonEncode({'path': request.url.path}),
        request.headers.containsKey(ifNoneMatchHeader) ? 304 : 200,
        headers: {
          contentTypeHeader: jsonContentType,
          etagHeader: '9875',
          cacheControlHeader: 'public, max-age=0',
          dateHeader: 'Wed, 21 Oct 2000 07:28:00 GMT',
          expiresHeader: HttpDate.format(DateTime.now().add(Duration(days: 10)))
        },
        request: request,
      ),
    ),
    options: options,
  );

  return client.get(url, options: options);
}

Future<http.Response> cacheControlExpired(CacheOptions options) {
  final url = Uri.http('ok.org', '/cache-control-expired');

  var client = CacheClient(
    MockClient(
      (request) async => http.Response(
        jsonEncode({'path': request.url.path}),
        request.headers.containsKey(ifNoneMatchHeader) ? 304 : 200,
        headers: {
          contentTypeHeader: jsonContentType,
          etagHeader: '9875',
          cacheControlHeader: 'public',
          expiresHeader: HttpDate.format(DateTime.now().add(Duration(days: 10)))
        },
        request: request,
      ),
    ),
    options: options,
  );

  return client.get(url, options: options);
}

Future<http.Response> cacheControlNoStore(CacheOptions options) {
  final url = Uri.http('ok.org', '/cache-control-nostore');

  var client = CacheClient(
    MockClient(
      (request) async => http.Response(
        jsonEncode({'path': request.url.path}),
        request.headers.containsKey(ifNoneMatchHeader) ? 304 : 200,
        headers: {
          contentTypeHeader: jsonContentType,
          etagHeader: '9875',
          cacheControlHeader: 'no-store',
          expiresHeader: HttpDate.format(DateTime.now().add(Duration(days: 10)))
        },
        request: request,
      ),
    ),
    options: options,
  );

  return client.get(url, options: options);
}

Future<http.Response> maxAge(CacheOptions options) {
  final url = Uri.http('ok.org', '/max-age');

  var client = CacheClient(
    MockClient(
      (request) async => http.Response(
        jsonEncode({'path': request.url.path}),
        200,
        headers: {
          contentTypeHeader: jsonContentType,
          lastModifiedHeader: HttpDate.format(DateTime.now()),
          cacheControlHeader: 'public, max-age=1',
        },
        request: request,
      ),
    ),
    options: options,
  );

  return client.get(url, options: options);
}

Future<http.Response> getException(
  CacheOptions options, {
  Map<String, String>? headers,
}) {
  final url = Uri.http('ok.org', '/exception');

  var client = CacheClient(
    MockClient(
      (request) async {
        if (headers != null && headers.containsKey('x-err')) {
          throw http.ClientException('socket exception');
        }

        return http.Response(
          jsonEncode({'path': request.url.path}),
          200,
          headers: {
            contentTypeHeader: jsonContentType,
            etagHeader: '1234',
            dateHeader: HttpDate.format(DateTime.now()),
          },
          request: request,
        );
      },
    ),
    options: options,
  );

  return client.get(url, options: options, headers: headers);
}

Future<http.Response> getOkNoDirective(CacheOptions options) {
  final url = Uri.http('ok.org', '/ok-nodirective');

  var client = CacheClient(
    MockClient(
      (request) async => http.Response(
        jsonEncode({'path': request.url.path}),
        200,
        headers: {
          contentTypeHeader: jsonContentType,
        },
        request: request,
      ),
    ),
    options: options,
  );

  return client.get(url, options: options);
}
