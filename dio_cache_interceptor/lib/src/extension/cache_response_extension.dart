import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/utils/content_serialization.dart';
import 'package:http_cache_core/http_cache_core.dart';

/// Cache key available in [Response]
const String extraCacheKey = '@cache_key@';

/// Available in [Response] if coming from network.
const String extraFromNetworkKey = '@fromNetwork@';

/// Available in [RequestOptions] to know when request has been sent.
const String extraRequestSentDateKey = '@requestSentDate@';

extension CacheResponseExtension on CacheResponse {
  Response toResponse(RequestOptions options, {bool fromNetwork = false}) {
    return Response(
      data: deserializeContent(options.responseType, content),
      extra: {extraCacheKey: key, extraFromNetworkKey: fromNetwork},
      headers: _getHeaders(),
      statusCode: statusCode,
      requestOptions: options,
    );
  }

  Future<CacheResponse> writeContent(
    CacheOptions options, {
    Response? response,
  }) async {
    final cipher = options.cipher;

    if (response != null) {
      final h = utf8.encode(jsonEncode(response.headers.map));
      final data = await serializeContent(
        response.requestOptions.responseType,
        response.data,
      );

      return copyWith(
        content: await cipher?.encryptContent(data) ?? data,
        headers: await cipher?.encryptContent(h) ?? h,
      );
    }

    return copyWith(
      content: await cipher?.encryptContent(content) ?? content,
      headers: await cipher?.encryptContent(headers) ?? headers,
    );
  }

  Headers _getHeaders() {
    final h = Headers();

    if (headers case final headers?) {
      final map = jsonDecode(utf8.decode(headers));
      map.forEach((key, value) => h.set(key, value));
    }

    return h;
  }
}
