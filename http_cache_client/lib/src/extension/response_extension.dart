import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_cache_core/http_cache_core.dart';

extension ResponseExtension on http.Response {
  Future<CacheResponse> toCacheResponse({
    required String key,
    required CacheOptions options,
    required DateTime requestDate,
  }) async {
    final respDate = getDateHeaderValue(headers[dateHeader]);
    final expires = getExpiresHeaderValue(headers[expiresHeader]);

    final h = utf8.encode(jsonEncode(headers));

    return CacheResponse(
      cacheControl: CacheControl.fromHeader(
        headersSplitValues[cacheControlHeader],
      ),
      content: await options.cipher?.encryptContent(bodyBytes) ?? bodyBytes,
      date: respDate,
      eTag: headers[etagHeader],
      expires: expires,
      headers: await options.cipher?.encryptContent(h) ?? h,
      key: key,
      lastModified: headers[lastModifiedHeader],
      maxStale: (options.maxStale != null)
          ? DateTime.now().toUtc().add(options.maxStale!)
          : null,
      priority: options.priority,
      requestDate: requestDate,
      responseDate: respDate ?? DateTime.now().toUtc(),
      url: request!.url.toString(),
      statusCode: statusCode,
    );
  }

  /// Update cache headers on 304
  ///
  /// https://tools.ietf.org/html/rfc7232#section-4.1
  void updateCacheHeaders(http.Response response) {
    void updateNonNullHeader(String headerKey) {
      final value = response.headers[headerKey];
      if (value != null) headers[headerKey] = value;
    }

    updateNonNullHeader(cacheControlHeader);
    updateNonNullHeader(dateHeader);
    updateNonNullHeader(etagHeader);
    updateNonNullHeader(lastModifiedHeader);
    updateNonNullHeader(expiresHeader);
    updateNonNullHeader(contentLocationHeader);
    updateNonNullHeader(varyHeader);
  }
}
