import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_cache_client/src/extension/cache_response_extension.dart';
import 'package:http_cache_client/src/extension/response_extension.dart';
import 'package:http_cache_client/src/model/http_base_response.dart';
import 'package:http_cache_core/http_cache_core.dart';

import '../model/http_base_request.dart';

part 'http_cache_client_cache_events.dart';
part 'http_cache_client_cache_utils.dart';

class CacheClient extends http.BaseClient {
  final CacheOptions _options;
  final CacheStore _store;
  final http.Client _inner;

  CacheClient(this._inner, {required CacheOptions options})
      : assert(options.store != null),
        _options = options,
        _store = options.store!;

  @override
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    CacheOptions? options,
  }) =>
      _onRequest(_getMethod, url, headers, _getCacheOptions(options));

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    CacheOptions? options,
  }) =>
      _onRequest(
          _postMethod, url, headers, _getCacheOptions(options), body, encoding);

  @override
  Future<String> read(
    Uri url, {
    Map<String, String>? headers,
    CacheOptions? options,
  }) async {
    final response =
        await get(url, headers: headers, options: _getCacheOptions(options));
    _checkResponseSuccess(url, response);
    return response.body;
  }

  @override
  Future<Uint8List> readBytes(
    Uri url, {
    Map<String, String>? headers,
    CacheOptions? options,
  }) async {
    final response =
        await get(url, headers: headers, options: _getCacheOptions(options));
    _checkResponseSuccess(url, response);
    return response.bodyBytes;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request);
  }

  /// Prepares a [Request] from given parameters.
  HttpBaseRequest _prepareRequest(
    CacheOptions options,
    String method,
    Uri url,
    Map<String, String>? headers, [
    Object? body,
    Encoding? encoding,
  ]) {
    var request = http.Request(method, url);

    if (headers != null) request.headers.addAll(headers);
    if (encoding != null) request.encoding = encoding;
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List) {
        request.bodyBytes = body.cast<int>();
      } else if (body is Map) {
        request.bodyFields = body.cast<String, String>();
      } else {
        throw ArgumentError('Invalid request body "$body".');
      }
    }

    return HttpBaseRequest(request, options, DateTime.now());
  }

  /// Sends a non-streaming [Request] and returns a non-streaming [Response].
  Future<http.Response> _sendUnstreamedRequest(HttpBaseRequest request) async {
    try {
      final response = await http.Response.fromStream(
        await send(request.inner),
      );
      return _onResponse(response, request);
    } on http.ClientException catch (ex) {
      return _onError(ex, request);
    }
  }

  /// Throws an error if [response] is not successful.
  void _checkResponseSuccess(Uri url, http.Response response) {
    if (response.statusCode < 400) return;
    var message = 'Request to $url failed with status ${response.statusCode}';
    if (response.reasonPhrase != null) {
      message = '$message: ${response.reasonPhrase}';
    }
    throw http.ClientException('$message.', url);
  }
}
