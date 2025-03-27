import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

void main() {
  group('CacheOptions', () {
    test('should create an instance with default values', () {
      final cacheOptions = CacheOptions(store: MemCacheStore());

      expect(cacheOptions.policy, CachePolicy.request);
      expect(cacheOptions.hitCacheOnErrorCodes, []);
      expect(cacheOptions.hitCacheOnNetworkFailure, false);
      expect(cacheOptions.keyBuilder, CacheOptions.defaultCacheKeyBuilder);
      expect(cacheOptions.maxStale, isNull);
      expect(cacheOptions.priority, CachePriority.normal);
      expect(cacheOptions.store, isNotNull);
      expect(cacheOptions.cipher, isNull);
      expect(cacheOptions.allowPostMethod, false);
    });

    test('should create an instance with custom values', () {
      final customStore = MemCacheStore();
      final cacheOptions = CacheOptions(
        policy: CachePolicy.request,
        hitCacheOnErrorCodes: [404],
        hitCacheOnNetworkFailure: true,
        maxStale: Duration(days: 1),
        priority: CachePriority.high,
        store: customStore,
        allowPostMethod: true,
      );

      expect(cacheOptions.policy, CachePolicy.request);
      expect(cacheOptions.hitCacheOnErrorCodes, [404]);
      expect(cacheOptions.hitCacheOnNetworkFailure, true);
      expect(cacheOptions.maxStale, Duration(days: 1));
      expect(cacheOptions.priority, CachePriority.high);
      expect(cacheOptions.store, customStore);
      expect(cacheOptions.allowPostMethod, true);
    });

    test('copyWith should create a new instance with updated values', () {
      final originalOptions = CacheOptions(store: MemCacheStore());
      final updatedOptions = originalOptions.copyWith(
        policy: CachePolicy.refresh,
        hitCacheOnErrorCodes: [500],
        maxStale: Duration(days: 2),
      );

      expect(updatedOptions.policy, CachePolicy.refresh);
      expect(updatedOptions.hitCacheOnErrorCodes, [500]);
      expect(updatedOptions.maxStale, Duration(days: 2));
      expect(updatedOptions.store, originalOptions.store);
    });

    test('copyWith should not modify the original instance', () {
      final originalOptions = CacheOptions(store: MemCacheStore());
      final originalStore = originalOptions.store;

      originalOptions.copyWith(policy: null);

      expect(originalOptions.policy, CachePolicy.request);
      expect(originalOptions.store, originalStore);
    });

    test('defaultCacheKeyBuilder', () {
      final options = CacheOptions(store: MemCacheStore());

      expect(options.keyBuilder, CacheOptions.defaultCacheKeyBuilder);

      var key = CacheOptions.defaultCacheKeyBuilder(
        url: Uri.parse('https://ok.org/apath'),
      );
      expect(key, '46fa4199-ec76-5f8f-90c5-b170cb5d5701');

      key = CacheOptions.defaultCacheKeyBuilder(
        url: Uri.parse('https://ok.org/apath?q=123abc'),
      );
      expect(key, '6f6b647e-c88f-5351-8f20-c4b2c3f9ac69');

      key = CacheOptions.defaultCacheKeyBuilder(
        url: Uri.parse('https://ok.org/apath?q=123abc#anchor'),
      );
      expect(key, '61362398-6517-541e-b119-aa50aeb1ef53');
    });
  });
}
