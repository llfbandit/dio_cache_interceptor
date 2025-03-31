import 'package:http/http.dart' as http;
import 'package:http_cache_client/src/model/http_base_request.dart';
import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

void main() {
  test('headerValuesAsList returns null when no header value', () {
    final inner = http.Request('GET', Uri.parse('https://ok.org'));

    final request = HttpBaseRequest(
      inner,
      CacheOptions(store: null),
      DateTime.now(),
    );

    expect(request.headerValuesAsList(cacheControlHeader), isNull);
  });

  test('headerValuesAsList simple', () {
    final inner = http.Request('GET', Uri.parse('https://ok.org'));
    inner.headers.addAll({cacheControlHeader: 'no-store'});

    final request = HttpBaseRequest(
      inner,
      CacheOptions(store: null),
      DateTime.now(),
    );

    final values = request.headerValuesAsList(cacheControlHeader);
    expect(values, isNotNull);
    expect(values?.first, equals('no-store'));
  });

  test('headerValuesAsList set-cookie', () {
    final inner = http.Request('GET', Uri.parse('https://ok.org'));
    inner.headers.addAll({
      'set-cookie':
          'id=a3fWa; Max-Age=2592000; Expires=Wed, 21 Oct 2015 07:28:00 GMT'
    });

    final request = HttpBaseRequest(
      inner,
      CacheOptions(store: null),
      DateTime.now(),
    );

    final values = request.headerValuesAsList('set-cookie');
    expect(values, isNotNull);
    expect(
        values?.first,
        equals(
            'id=a3fWa; Max-Age=2592000; Expires=Wed, 21 Oct 2015 07:28:00 GMT'));
    expect(
        values?.last,
        equals(
            'id=a3fWa; Max-Age=2592000; Expires=Wed, 21 Oct 2015 07:28:00 GMT'));
  });

  test('headerValuesAsList set-cookie', () {
    final inner = http.Request('GET', Uri.parse('https://ok.org'));
    inner.headers.addAll(
      {cacheControlHeader: 'no-cache, private,max-age=3600'},
    );

    final request = HttpBaseRequest(
      inner,
      CacheOptions(store: null),
      DateTime.now(),
    );

    final values = request.headerValuesAsList(cacheControlHeader);
    expect(values, isNotNull);
    expect(values?.first, equals('no-cache'));
    expect(values![1], equals('private'));
    expect(values.last, equals('max-age=3600'));
  });

  test('setHeader null value', () {
    final inner = http.Request('GET', Uri.parse('https://ok.org'));
    inner.headers.addAll(
      {cacheControlHeader: 'no-cache, private,max-age=3600'},
    );

    final request = HttpBaseRequest(
      inner,
      CacheOptions(store: null),
      DateTime.now(),
    );

    var values = request.headerValuesAsList(cacheControlHeader);
    expect(values, isNotNull);

    request.setHeader(cacheControlHeader, null);
    values = request.headerValuesAsList(cacheControlHeader);
    expect(values, isNull);
  });

  test('setHeader assign value', () {
    final inner = http.Request('GET', Uri.parse('https://ok.org'));
    inner.headers.addAll(
      {cacheControlHeader: 'no-cache, private,max-age=3600'},
    );

    final request = HttpBaseRequest(
      inner,
      CacheOptions(store: null),
      DateTime.now(),
    );

    var values = request.headerValuesAsList(cacheControlHeader);
    expect(values?.length, 3);

    request.setHeader(cacheControlHeader, 'no-store');
    values = request.headerValuesAsList(cacheControlHeader);
    expect(values?.first, equals('no-store'));
  });

  test('requestDate returns given date', () {
    final inner = http.Request('GET', Uri.parse('https://ok.org'));

    final now = DateTime.now();

    final request = HttpBaseRequest(
      inner,
      CacheOptions(store: null),
      now,
    );

    expect(request.requestDate, now);
  });
}
