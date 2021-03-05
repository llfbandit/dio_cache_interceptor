import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:test/test.dart';

import 'mock_adapter.dart';

void main() {
  late Dio _dio;
  late CacheStore store;

  setUp(() async {
    _dio = Dio()..httpClientAdapter = MockAdapter();

    store = MemCacheStore();

    _dio.interceptors.add(
      DioCacheInterceptor(options: CacheOptions(store: store)),
    );
  });

  tearDown(() {
    _dio.close();
  });

  test('Fetch 200', () async {
    final resp = await _dio.get('${MockAdapter.mockBase}/ok');
    expect(resp.data['path'], equals('/ok'));
    expect(await store.exists(resp.extra[CacheResponse.cacheKey]), isTrue);
  });

  test('Fetch 304', () async {
    final resp = await _dio.get('${MockAdapter.mockBase}/ok');
    final cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(cacheKey), isTrue);

    final resp304 = await _dio.get(
      '${MockAdapter.mockBase}/ok',
      options: Options(headers: {'if-none-match': resp.headers['etag']}),
    );
    expect(resp304.statusCode == 304, isTrue);
    expect(resp.data['path'], equals('/ok'));
    expect(resp304.extra[CacheResponse.cacheKey], equals(cacheKey));
    expect(resp304.extra[CacheResponse.fromCache], equals(true));
  });
}
