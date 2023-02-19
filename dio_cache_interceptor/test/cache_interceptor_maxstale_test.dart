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
      '${MockHttpClientAdapter.mockBase}/ok-nodirective',
      options: options.toOptions(),
    );
  }

  test('maxStale from base', () async {
    setUpMaxStale();

    final resp = await request(options.copyWith(
      policy: CachePolicy.forceCache,
    ));

    expect(resp.statusCode, equals(200));
    expect(resp.extra[CacheResponse.cacheKey], isNotNull);
  });

  test('maxStale from request', () async {
    setUpDefault();

    final resp = await request(options.copyWith(
      policy: CachePolicy.forceCache,
      maxStale: const Nullable(Duration(seconds: 1)),
    ));

    expect(resp.statusCode, equals(200));
    expect(resp.extra[CacheResponse.cacheKey], isNotNull);
  });

  test('maxStale removal from base', () async {
    setUpMaxStale();

    // Request for the 1st time
    var resp = await request(options.copyWith(
      policy: CachePolicy.forceCache,
    ));
    var key = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(key), isTrue);

    await Future.delayed(const Duration(seconds: 2));

    // Request a 2nd time to ensure the cache entry is now deleted
    resp = await request(options.copyWith(maxStale: Nullable(null)));

    expect(await store.exists(key), isFalse);
  });

  test('maxStale removal from request', () async {
    setUpDefault();

    // Request for the 1st time
    var resp = await request(options.copyWith(
      policy: CachePolicy.forceCache,
      maxStale: const Nullable(Duration(seconds: 1)),
    ));
    var key = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(key), isTrue);

    await Future.delayed(const Duration(seconds: 2));

    // Request a 2nd time to postpone stale date
    // We wait for 2 second so the cache is now staled but we recover it
    resp = await request(options.copyWith(
      policy: CachePolicy.forceCache,
      maxStale: const Nullable(Duration(seconds: 1)),
    ));
    expect(await store.exists(key), isTrue);

    await Future.delayed(const Duration(seconds: 1));

    // Request for the last time without maxStale directive to ensure
    // the cache entry is now deleted
    resp = await request(options);

    expect(await store.exists(key), isFalse);
  });
}
