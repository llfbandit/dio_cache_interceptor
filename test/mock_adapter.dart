import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';

class MockAdapter extends HttpClientAdapter {
  static const String mockHost = 'mockserver';
  static const String mockBase = 'http://$mockHost';
  final _adapter = DefaultHttpClientAdapter();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List> requestStream,
    Future? cancelFuture,
  ) async {
    final uri = options.uri;

    switch (uri.path) {
      case '/ok':
        if (options.headers.containsKey('if-none-match')) {
          return ResponseBody.fromString(
            '',
            304,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType]
            },
          );
        }
        if (options.queryParameters.containsKey('x-err')) {
          return ResponseBody.fromString(
            '',
            500,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType]
            },
          );
        }
        return ResponseBody.fromString(
          jsonEncode({'path': uri.path}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
            'etag': ['1234'],
          },
        );
      case '/post':
        return ResponseBody.fromString(
          jsonEncode({'path': uri.path}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType]
          },
        );
      case '/ok-stream':
        return ResponseBody(
          File('./README.md').openRead().cast<Uint8List>(),
          200,
          headers: {
            Headers.contentLengthHeader: [
              File('./README.md').lengthSync().toString()
            ],
          },
        );

      case '/ok-bytes':
        {
          return ResponseBody.fromBytes(
            utf8.encode(jsonEncode({'path': uri.path})),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
      case '/expires':
        {
          return ResponseBody.fromBytes(
            utf8.encode(jsonEncode({'path': uri.path})),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
      default:
        return ResponseBody.fromString('', 404);
    }

    // return _adapter.fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {
    _adapter.close(force: force);
  }
}
