import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../content_serialization.dart';
import 'cache_priority.dart';

/// Wrapper on top of [Response].
class CacheResponse {
  /// Cache key available in [Response]
  static const String cacheKey = '@cache_key@';

  /// Key used by store
  final String key;

  /// Initial request URL
  final String url;

  /// Last modified header
  final String lastModified;

  /// Max stale expiry duration
  final Duration maxStale;

  /// ETag header
  final String eTag;

  /// Response body
  final List<int> content;

  /// Response headers
  final List<int> headers;

  /// Cache priority
  final CachePriority priority;

  CacheResponse({
    @required this.key,
    @required this.url,
    @required this.lastModified,
    @required this.maxStale,
    @required this.eTag,
    @required this.content,
    @required this.headers,
    @required this.priority,
  });

  Response toResponse(RequestOptions options) {
    final decHeaders = jsonDecode(utf8.decode(headers)) as Map<String, dynamic>;
    final h = Headers();

    decHeaders.forEach((key, value) {
      h.set(key, value);
    });

    return Response(
      data: deserializeContent(options.responseType, content),
      extra: options.extra..addAll({cacheKey: key}),
      headers: h,
      statusCode: HttpStatus.notModified,
      request: options,
    );
  }
}
