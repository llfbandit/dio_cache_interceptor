import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor/src/store/file_cache_store.dart';
import 'package:test/test.dart';

import 'mock_adapter.dart';

void main() {
  late Dio _dio;
  late CacheStore store;
  late CacheOptions options;

  setUp(() async {
    _dio = Dio()..httpClientAdapter = MockAdapter();

    store = FileCacheStore('${Directory.current.path}/test/data');
    await store.clean();
    options = CacheOptions(store: store);

    _dio.interceptors.add(
      DioCacheInterceptor(options: options),
    );
  });

  tearDown(() async {
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

  test('Fetch cacheStoreNo policy', () async {
    final resp = await _dio.get(
      '${MockAdapter.mockBase}/ok',
      options: Options(
        extra: options.copyWith(policy: CachePolicy.cacheStoreNo).toExtra(),
      ),
    );
    expect(resp.statusCode == 200, isTrue);
    expect(resp.extra[CacheResponse.cacheKey], isNull);
  });

  test('Fetch refresh policy', () async {
    final resp = await _dio.get('${MockAdapter.mockBase}/ok');
    final cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(cacheKey), isTrue);

    final resp200 = await _dio.get(
      '${MockAdapter.mockBase}/ok',
      options: Options(
        extra: options.copyWith(policy: CachePolicy.refresh).toExtra(),
      ),
    );
    expect(resp200.statusCode == 200, isTrue);
    expect(resp.data['path'], equals('/ok'));
  });

  test('Fetch cacheFirst policy', () async {
    final resp = await _dio.get('${MockAdapter.mockBase}/ok');
    final cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(cacheKey), isTrue);

    final resp304 = await _dio.get(
      '${MockAdapter.mockBase}/ok',
      options: Options(
        extra: options.copyWith(policy: CachePolicy.cacheFirst).toExtra(),
      ),
    );
    expect(resp304.statusCode == 304, isTrue);
    expect(resp.data['path'], equals('/ok'));
    expect(resp304.extra[CacheResponse.cacheKey], equals(cacheKey));
    expect(resp304.extra[CacheResponse.fromCache], equals(true));
  });

  test('Fetch post skip request', () async {
    final resp = await _dio.get('${MockAdapter.mockBase}/post');
    expect(resp.statusCode == 200, isTrue);
    expect(resp.data['path'], equals('/post'));
    expect(resp.extra[CacheResponse.cacheKey], isNull);
  });

  test('Fetch hitCacheOnErrorExcept 500', () async {
    final resp = await _dio.get('${MockAdapter.mockBase}/ok');
    final cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(cacheKey), isTrue);

    try {
      await _dio.get(
        '${MockAdapter.mockBase}/ok',
        queryParameters: {'x-err': 500},
        options: Options(
          extra: options.copyWith(hitCacheOnErrorExcept: [500]).toExtra(),
        ),
      );
    } catch (err) {
      expect((err as DioError).response?.statusCode, equals(500));
    }

    try {
      await _dio.get(
        '${MockAdapter.mockBase}/ok',
        queryParameters: {'x-err': 500},
        options: Options(
          extra: options.copyWith(hitCacheOnErrorExcept: null).toExtra(),
        ),
      );
    } catch (err) {
      expect((err as DioError).response?.statusCode, equals(500));
      return;
    }

    expect(false, isTrue);
  });
}
