import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:test/test.dart';

import 'mock_httpclient_adapter.dart';

void main() {
  late Dio dio;
  late CacheStore store;
  late CacheOptions options;

  setUp(() async {
    dio = Dio(BaseOptions(
      sendTimeout: Duration(seconds: 2),
      connectTimeout: Duration(seconds: 2),
      receiveTimeout: Duration(seconds: 2),
    ))
      ..httpClientAdapter = MockHttpClientAdapter();

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
      await store.exists(resp.extra[extraCacheKey] ?? ''),
      isFalse,
    );
  });

  test('Fetch canceled', () async {
    try {
      await dio.get(
        '${MockHttpClientAdapter.mockBase}/ok',
        cancelToken: CancelToken()..cancel(),
      );
    } catch (err) {
      expect(err is DioException, isTrue);
      expect((err as DioException).type == DioExceptionType.cancel, isTrue);
      return;
    }

    expect(false, isTrue, reason: 'Should never reach this check');
  });

  test('Fetch with cipher', () async {
    final cipherOptions = options.copyWith(
      cipher: CacheCipher(
        decrypt: (bytes) =>
            Future.value(bytes.reversed.toList(growable: false)),
        encrypt: (bytes) =>
            Future.value(bytes.reversed.toList(growable: false)),
      ),
    );

    var resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options: cipherOptions.toOptions(),
    );
    expect(await store.exists(resp.extra[extraCacheKey]), isTrue);
    expect(resp.data['path'], equals('/ok'));

    resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options: cipherOptions.toOptions(),
    );
    expect(await store.exists(resp.extra[extraCacheKey]), isTrue);
    expect(resp.data['path'], equals('/ok'));
  });

  test('Fetch 200', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok');
    expect(resp.data['path'], equals('/ok'));
    expect(await store.exists(resp.extra[extraCacheKey]), isTrue);
  });

  test('Fetch bytes 200', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok-bytes');
    expect(await store.exists(resp.extra[extraCacheKey]), isTrue);
  });

  test('Fetch 304', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok');
    final key = resp.extra[extraCacheKey];
    expect(await store.exists(key), isTrue);

    var resp304 = await dio.get('${MockHttpClientAdapter.mockBase}/ok');
    expect(resp304.statusCode, equals(200));
    expect(resp.data['path'], equals('/ok'));
    expect(resp304.extra[extraCacheKey], equals(key));
    expect(resp304.extra[extraFromNetworkKey], isTrue);
    expect(resp304.headers['etag'], equals(['5678']));
  });

  test('Fetch cacheStoreNo policy', () async {
    final resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options: options.copyWith(policy: CachePolicy.noCache).toOptions(),
    );
    expect(resp.statusCode, equals(200));
    expect(resp.extra[extraCacheKey], isNull);
  });

  test('Fetch force policy', () async {
    // 1st time fetch
    var resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok-nodirective',
      options: options.copyWith(policy: CachePolicy.forceCache).toOptions(),
    );
    expect(resp.statusCode, equals(200));
    expect(resp.extra[extraFromNetworkKey], isTrue);
    // 2nd time cache
    resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok-nodirective',
      options: options.copyWith(policy: CachePolicy.forceCache).toOptions(),
    );
    expect(resp.statusCode, equals(200));
    expect(resp.extra[extraFromNetworkKey], isFalse);
    // 3rd time fetch
    resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok-nodirective',
      options:
          options.copyWith(policy: CachePolicy.refreshForceCache).toOptions(),
    );
    expect(resp.statusCode, equals(200));
    expect(resp.extra[extraFromNetworkKey], isTrue);
  });

  test('Fetch refresh policy', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok');
    final key = resp.extra[extraCacheKey];
    expect(await store.exists(key), isTrue);

    final resp200 = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options: options
          .copyWith(
            policy: CachePolicy.refresh,
            maxStale: Duration(minutes: 10),
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
    expect(resp.extra[extraCacheKey], isNull);
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
    expect(resp.extra[extraCacheKey], isNotNull);
  });

  test('Fetch hitCacheOnErrorCodes 500', () async {
    var resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok');
    final key = resp.extra[extraCacheKey];
    expect(await store.exists(key), isTrue);
    expect(resp.statusCode, equals(200));

    try {
      resp = await dio.get(
        '${MockHttpClientAdapter.mockBase}/ok',
        options: Options(
          extra: options.copyWith(
              hitCacheOnErrorCodes: [], policy: CachePolicy.refresh).toExtra()
            ..addAll({'x-err': '500'}),
        ),
      );
    } catch (err) {
      expect((err as DioException).response?.statusCode, equals(500));
    }

    try {
      resp = await dio.get(
        '${MockHttpClientAdapter.mockBase}/ok',
        options: Options(
          extra: options.copyWith(
              hitCacheOnErrorCodes: [], policy: CachePolicy.refresh).toExtra()
            ..addAll({'x-err': '500'}),
        ),
      );
    } catch (err) {
      expect((err as DioException).response?.statusCode, equals(500));
      return;
    }

    expect(false, isTrue, reason: 'Should never reach this check');
  });

  test('Fetch hitCacheOnErrorCodes 500 valid', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok');
    final key = resp.extra[extraCacheKey];
    expect(await store.exists(key), isTrue);
    expect(resp.statusCode, equals(200));

    final resp2 = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options: Options(
        extra: options.copyWith(
            hitCacheOnErrorCodes: [500], policy: CachePolicy.refresh).toExtra()
          ..addAll({'x-err': '500'}),
      ),
    );

    expect(resp2.statusCode, equals(200));
    expect(resp2.data['path'], equals('/ok'));
  });

  test('Fetch hitCacheOnNetworkFailure valid', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/exception');
    final key = resp.extra[extraCacheKey];
    expect(await store.exists(key), isTrue);

    final resp2 = await dio.get(
      '${MockHttpClientAdapter.mockBase}/exception',
      options: Options(
        extra: options.copyWith(hitCacheOnNetworkFailure: true).toExtra()
          ..addAll({'x-err': '500'}),
      ),
    );

    expect(resp2.statusCode, equals(200));
    expect(resp2.data['path'], equals('/exception'));
  });

  test('Fetch Cache-Control', () async {
    final resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/cache-control',
    );
    var key = resp.extra[extraCacheKey];
    expect(await store.exists(key), isTrue);

    var resp304 = await dio.get(
      '${MockHttpClientAdapter.mockBase}/cache-control',
    );
    expect(resp304.statusCode, equals(200));
    expect(resp304.extra[extraCacheKey], equals(key));
    expect(resp304.extra[extraFromNetworkKey], isTrue);
  });

  test('Fetch Cache-Control expired with etag', () async {
    final resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/cache-control-expired',
    );
    var key = resp.extra[extraCacheKey];
    expect(await store.exists(key), isTrue);

    final resp304 = await dio.get(
      '${MockHttpClientAdapter.mockBase}/cache-control-expired',
    );
    expect(resp304.statusCode, equals(200));
    key = resp304.extra[extraCacheKey];
    expect(await store.exists(key), isTrue);
    expect(resp304.extra[extraFromNetworkKey], isTrue);
  });

  test('Fetch Cache-Control no-store', () async {
    final resp = await dio.get(
      '${MockHttpClientAdapter.mockBase}/cache-control-no-store',
    );
    final key = resp.extra[extraCacheKey];
    expect(key, isNull);
  });

  test('Fetch max-age', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/max-age');
    final key = resp.extra[extraCacheKey];
    final cacheResp = await store.get(key);
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
    final key = resp.extra[extraCacheKey];
    expect(key, isNull);
  });

  test('Fetch 304 handle in response flow', () async {
    final resp = await dio.get('${MockHttpClientAdapter.mockBase}/ok');
    final key = resp.extra[extraCacheKey];
    expect(await store.exists(key), isTrue);

    expect(resp.headers['etag'], ['1234']);

    final resp304 = await dio.get(
      '${MockHttpClientAdapter.mockBase}/ok',
      options: Options(validateStatus: (status) => status == 304),
    );

    expect(resp304.statusCode, equals(200));
    expect(resp304.extra[extraCacheKey], equals(key));
    expect(resp304.extra[extraFromNetworkKey], isTrue);

    final cacheResp = await store.get(key);
    expect(
      cacheResp?.content,
      equals(Uint8List.fromList('{"path":"/ok"}'.codeUnits)),
    );
    expect(cacheResp?.eTag, equals('5678'));
  });
}
