import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:http_cache_client/http_cache_client.dart';
import 'package:http_cache_core/http_cache_core.dart';

Future<http.Response> get(
  CacheOptions options, {
  Map<String, String>? headers,
}) {
  final url = Uri.http('ok.org', '/ok');

  var client = CacheClient(
    MockClient(
      (request) async => http.Response(
        jsonEncode({'path': request.url.path}),
        200,
        request: request,
      ),
    ),
    options: options,
  );

  return client.get(url, options: options, headers: headers);
}

Future<http.Response> post(
  CacheOptions options, {
  Object? body,
  Map<String, String>? headers,
  Encoding? encoding,
}) {
  final url = Uri.http('ok.org', '/post');

  var client = CacheClient(
    MockClient(
      (request) async => http.Response(
        request.body,
        200,
        request: request,
      ),
    ),
    options: options,
  );

  return client.post(
    url,
    body: body,
    headers: headers,
    encoding: encoding,
    options: options,
  );
}

Future<String> read(
  CacheOptions options, {
  Map<String, String>? headers,
}) {
  final url = Uri.http('ok.org', '/read');

  var client = CacheClient(
    MockClient(
      (request) async {
        final hasError = request.headers.containsKey('x-err');

        return http.Response(
          jsonEncode({'path': request.url.path}),
          hasError ? 500 : 200,
          request: request,
          reasonPhrase: hasError ? 'Internal server error' : null,
        );
      },
    ),
    options: options,
  );

  return client.read(url, options: options, headers: headers);
}

Future<Uint8List> readBytes(
  CacheOptions options, {
  Map<String, String>? headers,
}) {
  final url = Uri.http('ok.org', '/readBytes');

  var client = CacheClient(
    MockClient(
      (request) async => http.Response(
        jsonEncode({'path': request.url.path}),
        200,
        request: request,
      ),
    ),
    options: options,
  );

  return client.readBytes(url, options: options, headers: headers);
}
