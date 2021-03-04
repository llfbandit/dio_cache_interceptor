import 'dart:convert' show jsonDecode, utf8;

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/model/cache_control.dart';

import '../util/content_serialization.dart';
import 'cache_priority.dart';

/// Response representation from cache store.
class CacheResponse {
  /// Cache key available in [Response]
  static const String cacheKey = '@cache_key@';

  /// Available in [Response] if coming from this object.
  static const String fromCache = '@fromCache@';

  /// Response Cache-control header
  final CacheControl? cacheControl;

  /// Response body
  List<int>? content;

  /// Response Date header
  final DateTime? date;

  /// ETag header
  final String? eTag;

  /// Expires header
  final DateTime? expires;

  /// Response headers
  List<int>? headers;

  /// Key used by store
  final String key;

  /// Last-modified header
  final String? lastModified;

  /// Max stale expiry
  final DateTime? maxStale;

  /// Cache priority
  final CachePriority priority;

  /// Absolute date representing date/time when response has been received
  final DateTime responseDate;

  /// Initial request URL
  final String url;

  CacheResponse({
    required this.cacheControl,
    required this.content,
    required this.date,
    required this.eTag,
    required this.expires,
    required this.headers,
    required this.key,
    required this.lastModified,
    required this.maxStale,
    required this.priority,
    required this.responseDate,
    required this.url,
  });

  /// Returns date in seconds since epoch or null.
  int? getMaxStaleSeconds() {
    return maxStale?.millisecondsSinceEpoch;
  }

  Response toResponse(RequestOptions options) {
    final checkedHeaders = headers;
    final decHeaders = (checkedHeaders != null)
        ? jsonDecode(utf8.decode(checkedHeaders)) as Map<String, dynamic>
        : null;

    final h = Headers();
    decHeaders?.forEach((key, value) => h.set(key, value));

    return Response(
      data: deserializeContent(options.responseType, content),
      extra: {cacheKey: key, fromCache: true},
      headers: h,
      statusCode: 304,
      request: options,
    );
  }
}
