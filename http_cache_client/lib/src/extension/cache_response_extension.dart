import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_cache_client/src/model/http_base_request.dart';
import 'package:http_cache_core/http_cache_core.dart';

extension CacheResponseExtension on CacheResponse {
  http.Response toResponse(HttpBaseRequest request) {
    return http.Response.bytes(
      content ?? [],
      statusCode,
      headers: _getHeaders(),
      request: request.inner,
    );
  }

  Future<CacheResponse> writeContent(
    CacheOptions options, {
    http.Response? response,
  }) async {
    final cipher = options.cipher;

    if (response != null) {
      final h = utf8.encode(jsonEncode(response.headers));
      final bodyBytes = response.bodyBytes;

      return copyWith(
        content: await cipher?.encryptContent(bodyBytes) ?? bodyBytes,
        headers: await cipher?.encryptContent(h) ?? h,
      );
    }

    return copyWith(
      content: await cipher?.encryptContent(content) ?? content,
      headers: await cipher?.encryptContent(headers) ?? headers,
    );
  }

  Map<String, String> _getHeaders() {
    final h = <String, String>{};

    if (headers case final headers?) {
      final map = jsonDecode(utf8.decode(headers));
      map.forEach((key, value) => h[key] = value);
    }

    return h;
  }
}
