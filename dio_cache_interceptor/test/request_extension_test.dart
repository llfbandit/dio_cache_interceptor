import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/extension/request_extension.dart';
import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

void main() {
  test('request cache control from String', () {
    final cacheControlReference = [
      'max-age=1',
      'no-store',
      'no-cache',
      'public',
      'max-stale=2',
      'min-fresh=3',
      'must-revalidate',
    ];

    // Correctly formatted
    var rq = RequestOptions(
      path: 'https://foo.com',
      headers: {
        cacheControlHeader:
            'max-age=1, no-store, no-cache, public, max-stale=2, min-fresh=3, must-revalidate'
      },
    );

    expect(
      cacheControlReference,
      rq.headerValuesAsList(cacheControlHeader),
    );

    // Without spaces
    rq = RequestOptions(
      path: 'https://foo.com',
      headers: {
        cacheControlHeader:
            'max-age=1,no-store,no-cache,public,max-stale=2,min-fresh=3,must-revalidate'
      },
    );

    expect(
      cacheControlReference,
      rq.headerValuesAsList(cacheControlHeader),
    );
  });

  test('cache control with field name', () {
    final cacheControlReference = [
      'max-age=1',
      'no-store',
      'no-cache="set-cookie"',
      'public',
      'max-stale=2',
      'min-fresh=3',
      'must-revalidate',
    ];

    // Correctly formatted
    var rq = RequestOptions(
      path: 'https://foo.com',
      headers: {
        cacheControlHeader:
            'max-age=1, no-store, no-cache="set-cookie", public, max-stale=2, min-fresh=3, must-revalidate'
      },
    );

    expect(
      cacheControlReference,
      rq.headerValuesAsList(cacheControlHeader),
    );
  });
}
