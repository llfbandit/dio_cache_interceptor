import 'dart:convert';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:test/test.dart';

void main() {
  CacheResponse _buildResponse({
    DateTime? date,
    DateTime? expires,
    CacheControl? cacheControl,
  }) {
    final rqRespDate = date ?? DateTime.now();

    return CacheResponse(
      cacheControl: cacheControl ?? CacheControl(),
      content: utf8.encode('foo'),
      date: date,
      eTag: 'an etag',
      expires: expires,
      headers: null,
      key: 'foo',
      lastModified: null,
      maxStale: null,
      priority: CachePriority.normal,
      requestDate: rqRespDate.subtract(const Duration(milliseconds: 50)),
      responseDate: rqRespDate,
      url: 'https://foo.com',
    );
  }

  test('isExpired', () {
    var resp = _buildResponse(
      date: null,
      expires: null,
      cacheControl: CacheControl(),
    );
    expect(resp.isExpired(requestCaching: CacheControl()), isTrue);

    resp = _buildResponse(
      date: DateTime.now().subtract(const Duration(seconds: 12)),
      expires: null,
      cacheControl: CacheControl(maxAge: 10),
    );
    expect(resp.isExpired(requestCaching: CacheControl()), isTrue);

    // max-age takes precedence over expires
    resp = _buildResponse(
      date: DateTime.now().subtract(const Duration(seconds: 12)),
      expires: DateTime.now().add(const Duration(hours: 10)),
      cacheControl: CacheControl(maxAge: 10),
    );
    expect(resp.isExpired(requestCaching: CacheControl()), isTrue);

    // max-age is invalid check with expires
    resp = _buildResponse(
      date: DateTime.now().subtract(const Duration(seconds: 12)),
      expires: DateTime.now().add(const Duration(hours: 10)),
      cacheControl: CacheControl(maxAge: 0),
    );
    expect(resp.isExpired(requestCaching: CacheControl()), isTrue);

    resp = _buildResponse(
      date: null,
      expires: DateTime.now().subtract(const Duration(hours: 10)),
      cacheControl: CacheControl(),
    );
    expect(resp.isExpired(requestCaching: CacheControl()), isTrue);

    resp = _buildResponse(
      date: DateTime.now(),
      expires: DateTime.now().add(const Duration(hours: 10)),
      cacheControl: CacheControl(),
    );
    expect(resp.isExpired(requestCaching: CacheControl()), isFalse);
  });

  test('headers', () {
    final cacheControl1 = CacheControl(
      maxAge: 2,
      noCache: true,
      noStore: true,
      other: ['unknown'],
      privacy: 'public',
    );

    final cacheControl2 = CacheControl.fromHeader([
      'max-age=2, no-store, no-cache, public, unknown',
    ]);

    expect(cacheControl1.maxAge, equals(cacheControl2.maxAge));
    expect(cacheControl1.noCache, equals(cacheControl2.noCache));
    expect(cacheControl1.noStore, equals(cacheControl2.noStore));
    expect(cacheControl1.other, equals(cacheControl2.other));
    expect(cacheControl1.privacy, equals(cacheControl2.privacy));

    // Redo test with toHeader()
    final cacheControl3 = CacheControl.fromHeader([cacheControl2.toHeader()]);
    expect(cacheControl1.maxAge, equals(cacheControl3.maxAge));
    expect(cacheControl1.noCache, equals(cacheControl3.noCache));
    expect(cacheControl1.noStore, equals(cacheControl3.noStore));
    expect(cacheControl1.other, equals(cacheControl3.other));
    expect(cacheControl1.privacy, equals(cacheControl3.privacy));
  });
}
