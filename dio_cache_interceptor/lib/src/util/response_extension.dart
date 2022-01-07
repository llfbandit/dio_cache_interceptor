import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/util/contants.dart';

extension ResponseExtension on Response {
  /// Update cache headers on 304
  ///
  /// https://tools.ietf.org/html/rfc7232#section-4.1
  void updateCacheHeaders(Response<dynamic>? response) {
    if (response == null) return;
    _updateNonNullHeader(cacheControlHeader, response);
    _updateNonNullHeader(dateHeader, response);
    _updateNonNullHeader(etagHeader, response);
    _updateNonNullHeader(lastModifiedHeader, response);
    _updateNonNullHeader(expiresHeader, response);
    _updateNonNullHeader(contentLocationHeader, response);
    _updateNonNullHeader(varyHeader, response);
  }

  void _updateNonNullHeader(String headerKey, Response<dynamic> response) {
    final values = response.headers[headerKey];
    if (values != null) headers.map[headerKey] = values;
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
