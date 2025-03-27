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

  Map<String, String> _getHeaders() {
    final h = <String, String>{};

    if (headers case final headers?) {
      final map = jsonDecode(utf8.decode(headers));
      map.forEach((key, value) => h[key] = value);
    }

    return h;
  }
}
