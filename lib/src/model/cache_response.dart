import 'dart:convert' show jsonDecode, utf8;

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/model/cache_control.dart';

import '../util/content_serialization.dart';
import 'cache_priority.dart';

/// Response representation from cache store.
class CacheResponse {
  /// Cache key available in [Response]
  static const String cacheKey = '@cache_key@';

  /// Available in [Response] if coming from network.
  static const String fromNetwork = '@fromNetwork@';

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

  Response toResponse(RequestOptions options, {bool fromNetwork = false}) {
    return Response(
      data: deserializeContent(options.responseType, content),
      extra: {cacheKey: key, CacheResponse.fromNetwork: fromNetwork},
      headers: getHeaders(),
      statusCode: 304,
      request: options,
    );
  }

  Headers getHeaders() {
    final checkedHeaders = headers;
    final decHeaders = (checkedHeaders != null)
        ? jsonDecode(utf8.decode(checkedHeaders)) as Map<String, dynamic>
        : null;

    final h = Headers();
    decHeaders?.forEach((key, value) => h.set(key, value));

    return h;
  }

  /// Check if response is staled from [maxStale] option.
  bool isStaled() {
    return maxStale != null && maxStale!.isBefore(DateTime.now());
  }

  /// Check if cache-control fields invalidates cache entry
  /// with [date] header or [responseDate] if missing.
  ///
  /// Checking in order against:
  /// - no-cache,
  /// - max-age,
  /// - and expires header values.
  bool isExpired() {
    final cControl = cacheControl;
    final checkedDate = date ?? responseDate;

    if (cControl != null) {
      if (cControl.noCache ?? false) {
        return true;
      }

      final checkedMaxAge = cControl.maxAge;
      if (checkedMaxAge != null && checkedMaxAge > 0) {
        final maxDate = checkedDate.add(Duration(seconds: checkedMaxAge));
        return maxDate.isBefore(DateTime.now());
      }
    }

    final checkedExpires = expires;
    if (checkedExpires != null) {
      return checkedExpires.difference(checkedDate).isNegative;
    }

    return true;
  }
}
