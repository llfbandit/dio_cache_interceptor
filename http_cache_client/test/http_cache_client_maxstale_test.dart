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

    final resp = await getOkNoDirective(options.copyWith(
      policy: CachePolicy.forceCache,
    ));

    expect(resp.statusCode, equals(200));
    final key = options.keyBuilder(url: resp.request!.url);
    expect(await store.exists(key), isTrue);
  });

  test('maxStale from request', () async {
    setUpDefault();

    final resp = await getOkNoDirective(options.copyWith(
      policy: CachePolicy.forceCache,
      maxStale: const Duration(seconds: 1),
    ));

    expect(resp.statusCode, equals(200));
    final key = options.keyBuilder(url: resp.request!.url);
    expect(await store.exists(key), isTrue);
  });

  test('maxStale removal from base', () async {
    setUpMaxStale();

    // Request for the 1st time
    var resp = await getOkNoDirective(options.copyWith(
      policy: CachePolicy.forceCache,
    ));
    final key = options.keyBuilder(url: resp.request!.url);
    expect(await store.exists(key), isTrue);

    await Future.delayed(const Duration(seconds: 2));

    // Request a 2nd time to ensure the cache entry is now deleted
    resp = await getOkNoDirective(options.copyWith(maxStale: Duration.zero));

    expect(await store.exists(key), isFalse);
  });

  test('maxStale removal from request', () async {
    setUpDefault();

    // Request for the 1st time
    var resp = await getOkNoDirective(options.copyWith(
      policy: CachePolicy.forceCache,
      maxStale: const Duration(seconds: 1),
    ));
    final key = options.keyBuilder(url: resp.request!.url);
    expect(await store.exists(key), isTrue);

    await Future.delayed(const Duration(seconds: 2));

    // Request a 2nd time to postpone stale date
    // We wait for 2 second so the cache is now staled but we recover it
    resp = await getOkNoDirective(options.copyWith(
      policy: CachePolicy.forceCache,
      maxStale: const Duration(seconds: 1),
    ));
    expect(await store.exists(key), isTrue);

    await Future.delayed(const Duration(seconds: 1));

    // Request for the last time without maxStale directive to ensure
    // the cache entry is now deleted
    resp = await getOkNoDirective(options);

    expect(await store.exists(key), isFalse);
  });
}
