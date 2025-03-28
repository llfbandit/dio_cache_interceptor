import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

import 'http_cache_client_cache_call_mocks.dart';

void main() {
  late CacheStore store;
  late CacheOptions options;

  void setUpDefault() {
    store = MemCacheStore();
    options = CacheOptions(store: store);
  }

  void setUpMaxStale() {
    store = MemCacheStore();
    options = CacheOptions(
      store: store,
      maxStale: const Duration(seconds: 1),
    );
  }

  tearDown(() {
    store.close();
  });

  test('maxStale from base', () async {
    setUpMaxStale();

    // 1st time - request is stored in cache
    var resp = await getOk(options);
    final key = options.keyBuilder(url: resp.request!.url);
    expect(await store.exists(key), isTrue);

    // 2nd time - the response is restored from cache, no remote call
    await getOk(options);
    final cache1 = await store.get(key);
    expect(cache1?.isStaled(), isFalse);

    await Future.delayed(const Duration(seconds: 1));

    // 3rd time - the response is staled, remote call
    final cache2 = await store.get(key);
    expect(cache2?.isStaled(), isTrue);
    resp = await getOk(options);
    final cache3 = await store.get(key);
    expect(cache3?.isStaled(), isFalse);
  });

  test('maxStale from request', () async {
    setUpDefault();

    // 1st time - request is stored in cache
    var resp = await getOk(options.copyWith(
      maxStale: const Duration(seconds: 1),
    ));
    final key = options.keyBuilder(url: resp.request!.url);
    expect(await store.exists(key), isTrue);

    // 2nd time - the response is restored from cache, no remote call
    await getOk(options.copyWith(
      maxStale: const Duration(seconds: 1),
    ));
    final cache1 = await store.get(key);
    expect(cache1?.isStaled(), isFalse);

    await Future.delayed(const Duration(seconds: 1));

    // 3rd time - the response is staled, remote call
    final cache2 = await store.get(key);
    expect(cache2?.isStaled(), isTrue);
    resp = await getOk(options.copyWith(
      maxStale: const Duration(seconds: 1),
    ));
    final cache3 = await store.get(key);
    expect(cache3?.isStaled(), isFalse);
  });
}
