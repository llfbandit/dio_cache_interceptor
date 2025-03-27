// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert' show jsonDecode, utf8;
import 'dart:math';

import 'package:collection/collection.dart';

import '../model.dart';

/// Response representation from cache store.
class CacheResponse {
  /// Response Cache-control header
  final CacheControl cacheControl;

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

  /// Max stale expiry from [CacheOptions].
  final DateTime? maxStale;

  /// Cache priority
  final CachePriority priority;

  /// Absolute date representing date/time when request has been sent
  final DateTime requestDate;

  /// Absolute date representing date/time when response has been received
  final DateTime responseDate;

  /// Initial request URL
  final String url;

  /// Initial status code to forward it when reloading from cache.
  final int statusCode;

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
    required this.requestDate,
    required this.responseDate,
    required this.url,
    required this.statusCode,
  });

  /// Checks if response is staled from [maxStale] option.
  bool isStaled() {
    return maxStale?.isBefore(DateTime.now()) ?? false;
  }

  /// Checks if response is expired.
  bool isExpired(CacheControl rqCacheCtrl) {
    final respCacheCtrl = cacheControl;

    final ageMillis = _cacheResponseAge();

    var freshMillis = _computeFreshnessLifetime();
    final maxAge = rqCacheCtrl.maxAge;
    if (maxAge != -1) {
      freshMillis = min(freshMillis, maxAge * 1000);
    }

    var maxStaleMillis = 0;
    final maxStale = rqCacheCtrl.maxStale;
    if (!respCacheCtrl.mustRevalidate && maxStale != -1) {
      maxStaleMillis = maxStale * 1000;
    }

    var minFreshMillis = 0;
    final minFresh = rqCacheCtrl.minFresh;
    if (minFresh != -1) {
      minFreshMillis = minFresh * 1000;
    }

    if (ageMillis + minFreshMillis < freshMillis + maxStaleMillis) {
      return false;
    }

    return true;
  }

  Map<String, dynamic> getHeaders() {
    if (headers case final headers?) {
      return jsonDecode(utf8.decode(headers));
    }

    return {};
  }

  /// Returns the current age of the response, in milliseconds.
  /// Calculating Age.
  /// https://datatracker.ietf.org/doc/html/rfc7234#section-4.2.3
  int _cacheResponseAge() {
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    final servedDate = date;
    final sentRequestMillis = requestDate.millisecondsSinceEpoch;
    final receivedResponseMillis = responseDate.millisecondsSinceEpoch;

    final headers = getHeaders();
    final ageSeconds = (headers[ageHeader] is String)
        ? int.tryParse(headers[ageHeader]) ?? -1
        : -1;

    final apparentReceivedAge = (servedDate != null)
        ? max(0, receivedResponseMillis - servedDate.millisecondsSinceEpoch)
        : 0;

    final receivedAge = (ageSeconds > -1)
        ? max(apparentReceivedAge, ageSeconds * 1000)
        : apparentReceivedAge;

    final responseDuration = receivedResponseMillis - sentRequestMillis;
    final residentDuration = nowMillis - receivedResponseMillis;

    return receivedAge + responseDuration + residentDuration;
  }

  /// Returns the number of milliseconds that the response was fresh for.
  /// Calculating Freshness Lifetime.
  /// https://datatracker.ietf.org/doc/html/rfc7234#section-4.2.1
  int _computeFreshnessLifetime() {
    final maxAge = cacheControl.maxAge;
    if (maxAge != -1) {
      return maxAge * 1000;
    }

    final checkedExpires = expires;
    if (checkedExpires != null) {
      final delta =
          checkedExpires.difference(date ?? responseDate).inMilliseconds;
      return (delta > 0) ? delta : 0;
    }

    if (lastModified != null && Uri.parse(url).query.isEmpty) {
      final sentRequestMillis = requestDate.millisecondsSinceEpoch;
      // As recommended by the HTTP RFC, the max age of a document
      // should be defaulted to 10% of the document's age
      // at the time it was served.
      // Default expiration dates aren't used for URIs containing a query.
      final servedMillis = date?.millisecondsSinceEpoch ?? sentRequestMillis;
      final delta =
          servedMillis - HttpDate.parse(lastModified!).millisecondsSinceEpoch;
      return ((delta > 0) ? delta / 10 : 0).round();
    }

    return 0;
  }

  Future<CacheResponse> readContent(CacheOptions options) async {
    final cipher = options.cipher;

    return copyWith(
      content: await cipher?.decryptContent(content) ?? content,
      headers: await cipher?.decryptContent(headers) ?? headers,
    );
  }

  Future<CacheResponse> writeContent(CacheOptions options) async {
    final cipher = options.cipher;

    return copyWith(
      content: await cipher?.encryptContent(content) ?? content,
      headers: await cipher?.encryptContent(headers) ?? headers,
    );
  }

  CacheResponse copyWith({
    CacheControl? cacheControl,
    List<int>? content,
    DateTime? date,
    String? eTag,
    DateTime? expires,
    List<int>? headers,
    String? key,
    String? lastModified,
    DateTime? maxStale,
    CachePriority? priority,
    DateTime? requestDate,
    DateTime? responseDate,
    String? url,
    int? statusCode,
  }) {
    return CacheResponse(
      cacheControl: cacheControl ?? this.cacheControl,
      content: content ?? this.content,
      date: date ?? this.date,
      eTag: eTag ?? this.eTag,
      expires: expires ?? this.expires,
      headers: headers ?? this.headers,
      key: key ?? this.key,
      lastModified: lastModified ?? this.lastModified,
      maxStale: maxStale ?? this.maxStale,
      priority: priority ?? this.priority,
      requestDate: requestDate ?? this.requestDate,
      responseDate: responseDate ?? this.responseDate,
      url: url ?? this.url,
      statusCode: statusCode ?? this.statusCode,
    );
  }

  @override
  bool operator ==(covariant CacheResponse other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.cacheControl == cacheControl &&
        listEquals(other.content, content) &&
        other.date == date &&
        other.eTag == eTag &&
        other.expires == expires &&
        listEquals(other.headers, headers) &&
        other.key == key &&
        other.lastModified == lastModified &&
        other.maxStale == maxStale &&
        other.priority == priority &&
        other.url == url &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode {
    return cacheControl.hashCode ^
        content.hashCode ^
        date.hashCode ^
        eTag.hashCode ^
        expires.hashCode ^
        headers.hashCode ^
        key.hashCode ^
        lastModified.hashCode ^
        maxStale.hashCode ^
        priority.hashCode ^
        url.hashCode ^
        statusCode.hashCode;
  }
}
