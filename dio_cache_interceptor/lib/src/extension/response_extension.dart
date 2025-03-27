import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/extension/cache_response_extension.dart';
import 'package:dio_cache_interceptor/src/utils/content_serialization.dart';
import 'package:http_cache_core/http_cache_core.dart';

extension ResponseExtension on Response {
  Future<CacheResponse> toCacheResponse({
    required String key,
    required CacheOptions options,
  }) async {
    final date = getDateHeaderValue(headers[dateHeader]?.join(','));
    final expires = getExpiresHeaderValue(headers[expiresHeader]?.join(','));

    final h = utf8.encode(jsonEncode(headers.map));
    final content = await serializeContent(
      requestOptions.responseType,
      data,
    );

    return CacheResponse(
      cacheControl: CacheControl.fromHeader(headers[cacheControlHeader]),
      content: await options.cipher?.encryptContent(content) ?? content,
      date: date,
      eTag: headers[etagHeader]?.join(','),
      expires: expires,
      headers: await options.cipher?.encryptContent(h) ?? h,
      key: key,
      lastModified: headers[lastModifiedHeader]?.join(','),
      maxStale: (options.maxStale != null)
          ? DateTime.now().toUtc().add(options.maxStale!)
          : null,
      priority: options.priority,
      requestDate: requestOptions.extra[extraRequestSentDateKey],
      responseDate: DateTime.now().toUtc(),
      url: requestOptions.uri.toString(),
      statusCode: statusCode!,
    );
  }

  /// Update cache headers on 304
  ///
  /// https://tools.ietf.org/html/rfc7232#section-4.1
  void updateCacheHeaders(Response<dynamic> response) {
    void updateNonNullHeader(String headerKey) {
      final values = response.headers[headerKey];
      if (values != null) headers.map[headerKey] = values;
    }

    updateNonNullHeader(cacheControlHeader);
    updateNonNullHeader(dateHeader);
    updateNonNullHeader(etagHeader);
    updateNonNullHeader(lastModifiedHeader);
    updateNonNullHeader(expiresHeader);
    updateNonNullHeader(contentLocationHeader);
    updateNonNullHeader(varyHeader);
  }

  /// Checks if disposition of the response is attachment
  /// or response type is stream since content-disposition can be missing
  /// when simply calling dio.download method.
  bool isAttachment() {
    if (requestOptions.responseType == ResponseType.stream) return true;

    final disposition = headers['content-disposition'];

    if (disposition != null) {
      for (final value in disposition) {
        for (final expandedValue in value.split(';')) {
          if (expandedValue.trim().toLowerCase().contains('attachment')) {
            return true;
          }
        }
      }
    }

    return false;
  }
}
