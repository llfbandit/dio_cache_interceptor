import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

import 'http_cache_client_call_mocks.dart';

void main() {
  late CacheStore store;
  late CacheOptions options;

  setUp(() async {
    store = MemCacheStore();
    await store.clean();
    options = CacheOptions(store: store);
  });

  test('GET', () async {
    final resp = await get(options);

    expect(jsonDecode(resp.body)['path'], equals('/ok'));
    expect(resp.statusCode, equals(200));
  });

  test('POST - String', () async {
    final body = 'body \\ éà&,ù';
    final resp = await post(options, body: body);

    expect(resp.body, equals(body));
    expect(resp.statusCode, equals(200));
  });

  test('POST - List', () async {
    final body = utf8.encode('body \\ éà&,ù');
    final resp = await post(options, body: body);

    expect(resp.body, equals(utf8.decode(body)));
    expect(resp.statusCode, equals(200));
  });

  test('POST - Map', () async {
    final body = {'body': 'body \\ éà&,ù'};
    final resp = await post(
      options,
      body: body,
      headers: {contentTypeHeader: 'application/x-www-form-urlencoded'},
      encoding: latin1,
    );

    expect(resp.body, equals('body=body+%5C+%E9%E0%26%2C%F9'));
    expect(resp.statusCode, equals(200));
  });

  test('POST - ArgumentError', () async {
    expect(
      () async => await post(options, body: Object()),
      throwsA(TypeMatcher<ArgumentError>()),
    );
  });

  test('read', () async {
    final resp = await read(options);

    expect(resp, equals('{"path":"/read"}'));
  });

  test('readBytes', () async {
    final resp = await readBytes(options);

    expect(utf8.decode(resp), equals('{"path":"/readBytes"}'));
  });

  test('read - error', () async {
    expect(
      () async => await read(options, headers: {'x-err': '500'}),
      throwsA(TypeMatcher<http.ClientException>()),
    );
  });
}
