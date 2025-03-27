import 'dart:convert';

import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

void main() {
  CacheResponse buildResponse({
    DateTime? date,
    DateTime? expires,
    CacheControl? cacheControl,
  }) {
    final rqRespDate = date ?? DateTime.now();

    return CacheResponse(
      cacheControl: cacheControl ?? CacheControl(),
      content: utf8.encode('foo'),
      date: date,
      eTag: 'an, etag',
      expires: expires,
      headers: null,
      key: 'foo',
      lastModified: null,
      maxStale: null,
      priority: CachePriority.normal,
      requestDate: rqRespDate.subtract(const Duration(milliseconds: 50)),
      responseDate: rqRespDate,
      url: 'https://foo.com',
      statusCode: 200,
    );
  }

  test('isExpired', () {
    var resp = buildResponse(
      date: null,
      expires: null,
      cacheControl: CacheControl(),
    );
    expect(resp.isExpired(CacheControl()), isTrue);

    resp = buildResponse(
      date: DateTime.now().subtract(const Duration(seconds: 12)),
      expires: null,
      cacheControl: CacheControl(maxAge: 10),
    );
    expect(resp.isExpired(CacheControl()), isTrue);

    // max-age takes precedence over expires
    resp = buildResponse(
      date: DateTime.now().subtract(const Duration(seconds: 12)),
      expires: DateTime.now().add(const Duration(hours: 10)),
      cacheControl: CacheControl(maxAge: 10),
    );
    expect(resp.isExpired(CacheControl()), isTrue);

    // max-age is invalid check with expires
    resp = buildResponse(
      date: DateTime.now().subtract(const Duration(seconds: 12)),
      expires: DateTime.now().add(const Duration(hours: 10)),
      cacheControl: CacheControl(maxAge: 0),
    );
    expect(resp.isExpired(CacheControl()), isTrue);

    resp = buildResponse(
      date: null,
      expires: DateTime.now().subtract(const Duration(hours: 10)),
      cacheControl: CacheControl(),
    );
    expect(resp.isExpired(CacheControl()), isTrue);

    resp = buildResponse(
      date: DateTime.now(),
      expires: DateTime.now().add(const Duration(hours: 10)),
      cacheControl: CacheControl(),
    );
    expect(resp.isExpired(CacheControl()), isFalse);
  });

  test('Default headers', () {
    final cacheControl1 = CacheControl();
    expect(cacheControl1.maxAge, equals(-1));
    expect(cacheControl1.noCache, false);
    expect(cacheControl1.noStore, false);
    expect(cacheControl1.other, equals([]));
    expect(cacheControl1.privacy, isNull);
    expect(cacheControl1.maxStale, equals(-1));
    expect(cacheControl1.minFresh, equals(-1));
    expect(cacheControl1.mustRevalidate, equals(false));

    expect(cacheControl1, equals(CacheControl.fromHeader(null)));
    expect(cacheControl1, equals(CacheControl.fromHeader([])));
  });

  test('headers', () {
    final cacheControl1 = CacheControl(
      maxAge: 1,
      noCache: true,
      noStore: true,
      other: ['unknown', 'unknown2=2'],
      privacy: 'public',
      maxStale: 2,
      minFresh: 3,
      mustRevalidate: true,
    );

    final cacheControl2 = CacheControl.fromHeader([
      'max-age=1, no-store, no-cache, public, unknown, unknown2=2, max-stale=2, min-fresh=3, must-revalidate',
    ]);

    expect(cacheControl1, equals(cacheControl2));

    // Redo test with toHeader()
    final cacheControl3 = CacheControl.fromHeader([cacheControl2.toHeader()]);
    expect(cacheControl1, equals(cacheControl3));
  });

  test('headers splitted', () {
    final cacheControl1 = CacheControl(
      maxAge: 1,
      noCache: true,
      noStore: true,
      privacy: 'public',
      maxStale: 2,
      minFresh: 3,
      mustRevalidate: true,
    );

    final cacheControl2 = CacheControl.fromHeader([
      'max-age=1',
      'no-store',
      'no-cache',
      'public',
      'max-stale=2',
      'min-fresh=3',
      'must-revalidate',
    ]);

    expect(cacheControl1, equals(cacheControl2));

    // Redo test with toHeader()
    final cacheControl3 = CacheControl.fromHeader([cacheControl2.toHeader()]);
    expect(cacheControl1, equals(cacheControl3));
  });
}
