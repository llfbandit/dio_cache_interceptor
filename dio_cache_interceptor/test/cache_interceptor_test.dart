import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:test/test.dart';

import 'mock_httpclient_adapter.dart';

void main() {
  late Dio dio;
  late CacheStore store;
  late CacheOptions options;

  setUp(() async {
    dio = Dio()..httpClientAdapter = MockHttpClientAdapter();

    store = MemCacheStore();
    await store.clean();
    options = CacheOptions(store: store);

    dio.interceptors.add(DioCacheInterceptor(options: options));
  });

  tearDown(() async {
    dio.close();
  });

  test('Fetch stream 200', () async {
    final resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok-stream',
      options: Options(responseType: ResponseType.stream),
    );
    expect(
      await store.exists(resp.extra[CacheResponse.cacheKey] ?? ''),
      isFalse,
    );
  });

  // test('Fetch canceled', () async {
  //   try {
  //     await dio.get(
  //       '${MockHttpClientAdapter.mockBase}/ok',
  //       cancelToken: CancelToken()..cancel(),
  //     );
  //   } catch (err) {
  //     expect(err is DioError, isTrue);
  //     expect((err as DioError).type == DioErrorType.cancel, isTrue);
  //     return;
  //   }

  //   expect(false, isTrue, reason: 'Should never reach this check');
  // });

  test('Fetch with cipher', () async {
    final cipherOptions = options.copyWith(
      cipher: Nullable(CacheCipher(
        decrypt: (bytes) =>
            Future.value(bytes.reversed.toList(growable: false)),
        encrypt: (bytes) =>
            Future.value(bytes.reversed.toList(growable: false)),
      )),
    );

    var resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options: cipherOptions.toOptions(),
    );
    expect(await store.exists(resp.extra[CacheResponse.cacheKey]), isTrue);

    resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options:
          cipherOptions.copyWith(policy: CachePolicy.forceCache).toOptions(),
    );
    expect(resp.data['path'], equals('/ok'));
  });

  test('Fetch 200', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok');
    expect(resp.data['path'], equals('/ok'));
    expect(await store.exists(resp.extra[CacheResponse.cacheKey]), isTrue);
  });

  test('Fetch bytes 200', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok-bytes');
    expect(await store.exists(resp.extra[CacheResponse.cacheKey]), isTrue);
  });

  test('Fetch 304', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok');
    final cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(cacheKey), isTrue);

    final resp304 = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options: Options(headers: {'if-none-match': resp.headers['etag']}),
    );
    expect(resp304.statusCode, equals(304));
    expect(resp.data['path'], equals('/ok'));
    expect(resp304.extra[CacheResponse.cacheKey], equals(cacheKey));
    expect(resp304.extra[CacheResponse.fromNetwork], isTrue);
    expect(resp304.headers['etag'], equals(['5678']));
  });

  test('Fetch 304 handle in response flow', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok');
    final cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(cacheKey), isTrue);

    final resp304 = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options: Options(
        headers: {'if-none-match': resp.headers['etag']},
        validateStatus: (status) => status != null && ((status >= 200 && status < 300) || status == 304),
      ),
    );
    expect(resp304.statusCode, equals(304));
    expect(resp.data['path'], equals('/ok'));
    expect(resp304.extra[CacheResponse.cacheKey], equals(cacheKey));
    expect(resp304.extra[CacheResponse.fromNetwork], isTrue);
    expect(resp304.headers['etag'], equals(['5678']));
  });

  test('Fetch cacheStoreNo policy', () async {
    final resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options: options.copyWith(policy: CachePolicy.noCache).toOptions(),
    );
    expect(resp.statusCode, equals(200));
    expect(resp.extra[CacheResponse.cacheKey], isNull);
  });

  test('Fetch force policy', () async {
    // 1st time fetch
    var resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok-nodirective',
      options: options.copyWith(policy: CachePolicy.forceCache).toOptions(),
    );
    expect(resp.statusCode, equals(200));
    expect(resp.extra[CacheResponse.fromNetwork], isTrue);
    // 2nd time cache
    resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok-nodirective',
      options: options.copyWith(policy: CachePolicy.forceCache).toOptions(),
    );
    expect(resp.statusCode, equals(304));
    expect(resp.extra[CacheResponse.fromNetwork], isFalse);
    // 3rd time fetch
    resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok-nodirective',
      options:
          options.copyWith(policy: CachePolicy.refreshForceCache).toOptions(),
    );
    expect(resp.statusCode, equals(200));
    expect(resp.extra[CacheResponse.fromNetwork], isTrue);
  });

  test('Fetch refresh policy', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok');
    final cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(cacheKey), isTrue);

    final resp200 = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options: options
          .copyWith(
            policy: CachePolicy.refresh,
            maxStale: Nullable(Duration(minutes: 10)),
          )
          .toOptions(),
    );
    expect(resp200.statusCode, equals(200));
    expect(resp.data['path'], equals('/ok'));
  });

  test('Fetch post skip request', () async {
    final resp = await dio.post('${MockHttpClientAdapter.mockBase}/post');
    expect(resp.statusCode, equals(200));
    expect(resp.data['path'], equals('/post'));
    expect(resp.extra[CacheResponse.cacheKey], isNull);
  });

  test('Fetch post doesn\'t skip request', () async {
    final resp = await dio.post(
      '${MockHttpClientAdapter.mockBase}/post',
      options: Options(
        extra: options.copyWith(allowPostMethod: true).toExtra(),
      ),
    );

    expect(resp.statusCode, equals(200));
    expect(resp.data['path'], equals('/post'));
    expect(resp.extra[CacheResponse.cacheKey], isNotNull);
  });

  test('Fetch hitCacheOnErrorExcept 500', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok');
    final cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(cacheKey), isTrue);

    try {
      await dio.get(
        '${MockHttpClientAdapter.mockBase}/ok',
        options: Options(
          extra: options
              .copyWith(
                  hitCacheOnErrorExcept: Nullable([500]),
                  policy: CachePolicy.refresh)
              .toExtra()
            ..addAll({'x-err': '500'}),
        ),
      );
    } catch (err) {
      expect((err as DioException).response?.statusCode, equals(500));
    }

    try {
      await dio.get(
        '${MockHttpClientAdapter.mockBase}/ok',
        options: Options(
          extra: options
              .copyWith(
                hitCacheOnErrorExcept: null,
                policy: CachePolicy.refresh,
              )
              .toExtra()
            ..addAll({'x-err': '500'}),
        ),
      );
    } catch (err) {
      expect((err as DioException).response?.statusCode, equals(500));
      return;
    }

    expect(false, isTrue, reason: 'Should never reach this check');
  });

  test('Fetch hitCacheOnErrorExcept 500 valid', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok');
    final cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(cacheKey), isTrue);

    final resp2 = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options: Options(
        extra: options
            .copyWith(
              hitCacheOnErrorExcept: Nullable([]),
              policy: CachePolicy.refresh,
            )
            .toExtra()
          ..addAll({'x-err': '500'}),
      ),
    );

    expect(resp2.statusCode, equals(304));
    expect(resp2.data['path'], equals('/ok'));
  });

  test('Fetch hitCacheOnErrorExcept socket exception valid', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/exception');
    final cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(cacheKey), isTrue);

    final resp2 = await dio.get(
      '${MockHttpClientAdapter.mockBase}/exception',
      options: Options(
        extra: options.copyWith(hitCacheOnErrorExcept: Nullable([])).toExtra()
          ..addAll({'x-err': '500'}),
      ),
    );

    expect(resp2.statusCode, equals(304));
    expect(resp2.data['path'], equals('/exception'));
  });

  test('Fetch Cache-Control', () async {
    final resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/cache-control',
    );
    var cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(cacheKey), isTrue);

    var resp304 = await dio.get(
      '${MockHttpClientAdapter.mockBase}/cache-control',
    );
    expect(resp304.statusCode, equals(304));
    expect(resp304.extra[CacheResponse.cacheKey], equals(cacheKey));
    expect(resp304.extra[CacheResponse.fromNetwork], isTrue);
  });

  test('Fetch Cache-Control expired', () async {
    final resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/cache-control-expired',
    );
    var cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(await store.exists(cacheKey), isTrue);

    final resp304 = await dio.get(
      '${MockHttpClientAdapter.mockBase}/cache-control-expired',
    );
    expect(resp304.statusCode, equals(304));
    cacheKey = resp304.extra[CacheResponse.cacheKey];
    expect(await store.exists(cacheKey), isTrue);
    expect(resp304.extra[CacheResponse.fromNetwork], isTrue);
  });

  test('Fetch Cache-Control no-store', () async {
    final resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/cache-control-no-store',
    );
    final cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(cacheKey, isNull);
  });

  test('Fetch max-age', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/max-age');
    final cacheKey = resp.extra[CacheResponse.cacheKey];
    final cacheResp = await store.get(cacheKey);
    expect(cacheResp, isNotNull);

    // We're before max-age: 1
    expect(cacheResp!.isExpired(CacheControl()), isFalse);
    // We're after max-age: 1
    await Future.delayed(const Duration(seconds: 1));
    expect(cacheResp.isExpired(CacheControl()), isTrue);
  });

  test('Skip downloads', () async {
    final resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/download',
    );
    final cacheKey = resp.extra[CacheResponse.cacheKey];
    expect(cacheKey, isNull);
  });
}
