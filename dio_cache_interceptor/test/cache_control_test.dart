import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor/src/util/contants.dart';
import 'package:dio_cache_interceptor/src/util/request_extension.dart';
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

  void compareCacheControls(CacheControl cc1, CacheControl cc2) {
    expect(cc1.maxAge, equals(cc2.maxAge));
    expect(cc1.noCache, equals(cc2.noCache));
    expect(cc1.noStore, equals(cc2.noStore));
    expect(cc1.other, equals(cc2.other));
    expect(cc1.privacy, equals(cc2.privacy));
    expect(cc1.maxStale, equals(cc2.maxStale));
    expect(cc1.minFresh, equals(cc2.minFresh));
    expect(cc1.mustRevalidate, equals(cc2.mustRevalidate));
  }

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

    compareCacheControls(cacheControl1, CacheControl.fromHeader(null));
    compareCacheControls(cacheControl1, CacheControl.fromHeader([]));
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

    compareCacheControls(cacheControl1, cacheControl2);

    // Redo test with toHeader()
    final cacheControl3 = CacheControl.fromHeader([cacheControl2.toHeader()]);
    compareCacheControls(cacheControl1, cacheControl3);
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

    compareCacheControls(cacheControl1, cacheControl2);

    // Redo test with toHeader()
    final cacheControl3 = CacheControl.fromHeader([cacheControl2.toHeader()]);
    compareCacheControls(cacheControl1, cacheControl3);
  });

  test('request cache control from String', () {
    final cacheControlReference = CacheControl.fromHeader([
      'max-age=1',
      'no-store',
      'no-cache',
      'public',
      'max-stale=2',
      'min-fresh=3',
      'must-revalidate',
    ].reversed.toList());

    // Correctly formatted
    var rq = RequestOptions(
      path: 'https://foo.com',
      headers: {
        cacheControlHeader:
            'max-age=1, no-store, no-cache, public, max-stale=2, min-fresh=3, must-revalidate'
      },
    );

    compareCacheControls(
      cacheControlReference,
      CacheControl.fromHeader(rq.headerValuesAsList(cacheControlHeader)),
    );

    // Without spaces
    rq = RequestOptions(
      path: 'https://foo.com',
      headers: {
        cacheControlHeader:
            'max-age=1,no-store,no-cache,public,max-stale=2,min-fresh=3,must-revalidate'
      },
    );

    compareCacheControls(
      cacheControlReference,
      CacheControl.fromHeader(rq.headerValuesAsList(cacheControlHeader)),
    );
  });
}
