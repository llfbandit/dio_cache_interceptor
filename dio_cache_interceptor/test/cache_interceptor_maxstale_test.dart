import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:test/test.dart';

import 'mock_httpclient_adapter.dart';

void main() {
  late Dio dio;
  late CacheStore store;
  late CacheOptions options;

  void setUpDefault() {
    dio = Dio()..httpClientAdapter = MockHttpClientAdapter();

    store = MemCacheStore();
    options = CacheOptions(store: store);

    dio.interceptors.add(DioCacheInterceptor(options: options));
  }

  void setUpMaxStale() {
    dio = Dio()..httpClientAdapter = MockHttpClientAdapter();

    store = MemCacheStore();
    options = CacheOptions(
      store: store,
      maxStale: const Duration(seconds: 1),
    );

    dio.interceptors.add(DioCacheInterceptor(options: options));
  }

  tearDown(() {
    dio.close();
    store.close();
  });

  Future<Response> request(CacheOptions options) {
    return dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options: options.toOptions(),
    );
  }

  test('maxStale from base', () async {
    setUpMaxStale();

    // 1st time - request is stored in cache
    var resp = await request(options);
    final key = resp.extra[extraCacheKey];
    expect(await store.exists(key), isTrue);

    // 2nd time - the response is restored from cache, no remote call
    resp = await request(options.copyWith(policy: CachePolicy.forceCache));
    var fromNetwork = resp.extra[extraFromNetworkKey];
    expect(fromNetwork, isFalse);

    await Future.delayed(const Duration(seconds: 1));

    // 3rd time - the response is staled, remote call
    resp = await request(options.copyWith(policy: CachePolicy.forceCache));
    fromNetwork = resp.extra[extraFromNetworkKey];
    expect(fromNetwork, isTrue);
  });

  test('maxStale from request', () async {
    setUpDefault();

    // 1st time - request is stored in cache
    var resp = await request(options.copyWith(
      maxStale: const Duration(seconds: 1),
    ));
    final key = resp.extra[extraCacheKey];
    expect(await store.exists(key), isTrue);

    // 2nd time - the response is restored from cache, no remote call
    resp = await request(options.copyWith(policy: CachePolicy.forceCache));
    var fromNetwork = resp.extra[extraFromNetworkKey];
    expect(fromNetwork, isFalse);

    await Future.delayed(const Duration(seconds: 1));

    // 3rd time - the response is staled, remote call
    resp = await request(options.copyWith(
      policy: CachePolicy.forceCache,
      maxStale: const Duration(seconds: 1),
    ));
    fromNetwork = resp.extra[extraFromNetworkKey];
    expect(fromNetwork, isTrue);
  });
}
