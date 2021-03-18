import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/util/contants.dart';

extension ResponseExtension on Response {
  /// Update cache headers on 304
  ///
  /// https://tools.ietf.org/html/rfc7232#section-4.1
  void updateCacheHeaders(Response<dynamic> response) {
    _updateNonNullHeader(cacheControlHeader, response);
    _updateNonNullHeader(dateHeader, response);
    _updateNonNullHeader(etagHeader, response);
    _updateNonNullHeader(expiresHeader, response);
    _updateNonNullHeader(contentLocationHeader, response);
    _updateNonNullHeader(varyHeader, response);
  }

  void _updateNonNullHeader(String headerKey, Response<dynamic> response) {
    final values = response.headers[headerKey];
    if (values != null) headers.map[headerKey] = values;
  }
}
