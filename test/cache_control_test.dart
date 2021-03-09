import 'dart:convert';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:test/test.dart';

void main() {
  CacheResponse _buildResponse({
    DateTime? date,
    DateTime? expires,
    CacheControl? cacheControl,
  }) {
    return CacheResponse(
      cacheControl: cacheControl,
      content: utf8.encode('foo'),
      date: date,
      eTag: 'an etag',
      expires: expires,
      headers: null,
      key: 'foo',
      lastModified: null,
      maxStale: null,
      priority: CachePriority.normal,
      responseDate: DateTime.now(),
      url: 'https://foo.com',
    );
  }

  test('isExpired', () {
    var resp = _buildResponse(
      date: null,
      expires: null,
      cacheControl: CacheControl(),
    );
    expect(resp.isExpired(), isTrue);

    resp = _buildResponse(
      date: DateTime.now().subtract(const Duration(seconds: 12)),
      expires: null,
      cacheControl: CacheControl(maxAge: 10),
    );
    expect(resp.isExpired(), isTrue);

    // max-age takes precedence over expires
    resp = _buildResponse(
      date: DateTime.now().subtract(const Duration(seconds: 12)),
      expires: DateTime.now().add(const Duration(hours: 10)),
      cacheControl: CacheControl(maxAge: 10),
    );
    expect(resp.isExpired(), isTrue);

    // max-age is invalid check with expires
    resp = _buildResponse(
      date: DateTime.now().subtract(const Duration(seconds: 12)),
      expires: DateTime.now().add(const Duration(hours: 10)),
      cacheControl: CacheControl(maxAge: 0),
    );
    expect(resp.isExpired(), isFalse);

    resp = _buildResponse(
      date: null,
      expires: DateTime.now().subtract(const Duration(hours: 10)),
      cacheControl: CacheControl(),
    );
    expect(resp.isExpired(), isTrue);
  });
}
