import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/extension/request_extension.dart';
import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

void main() {
  test('getFlattenHeaders returns correct header', () {
    final cacheControlReference = [
      'max-age=1',
      'no-store',
      'no-cache="set-cookie"',
      'public',
      'max-stale=2',
      'min-fresh=3',
      'must-revalidate',
    ];

    // Correctly formatted from list
    var rq = RequestOptions(
      path: 'https://foo.com',
      headers: {cacheControlHeader: cacheControlReference},
    );

    expect(
      rq.getFlattenHeaders()[cacheControlHeader],
      cacheControlReference.join(', '),
    );

    // Without spaces from String
    final values =
        'max-age=1,no-store,no-cache,public,max-stale=2,min-fresh=3,must-revalidate';
    rq = RequestOptions(
      path: 'https://foo.com',
      headers: {cacheControlHeader: values},
    );

    expect(rq.getFlattenHeaders()[cacheControlHeader], values);
  });

  test('getFlattenHeaders cache control with field name', () {
    final cacheControlReference = [
      'max-age=1',
      'no-store',
      'no-cache="set-cookie"',
      'public',
      'max-stale=2',
      'min-fresh=3',
      'must-revalidate',
    ];

    var rq = RequestOptions(
      path: 'https://foo.com',
      headers: {cacheControlHeader: cacheControlReference},
    );

    expect(
      rq.getFlattenHeaders()[cacheControlHeader],
      cacheControlReference.join(', '),
    );
  });
}
