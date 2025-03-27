import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

void main() {
  test('isCacheCheckAllowed returns true on NOT_MODIFIED', () {
    expect(isCacheCheckAllowed(304, CacheOptions(store: null)), isTrue);
  });

  test('isCacheCheckAllowed returns true on network failure with option', () {
    expect(
      isCacheCheckAllowed(
          null, CacheOptions(store: null, hitCacheOnNetworkFailure: true)),
      isTrue,
    );
  });

  test('isCacheCheckAllowed returns false on network failure', () {
    expect(
      isCacheCheckAllowed(null, CacheOptions(store: null)),
      isFalse,
    );
  });

  test('isCacheCheckAllowed returns false on hitCacheOnErrorCodes', () {
    expect(
      isCacheCheckAllowed(500, CacheOptions(store: null)),
      isFalse,
    );
  });

  test('isCacheCheckAllowed returns true on hitCacheOnErrorCodes', () {
    expect(
      isCacheCheckAllowed(
          500, CacheOptions(store: null, hitCacheOnErrorCodes: [500])),
      isTrue,
    );
  });
}
