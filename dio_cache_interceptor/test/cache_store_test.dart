import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:test/test.dart';

void main() {
  test('pathExists', () {
    CacheStore store = MemCacheStore();

    // Match regex with no query params
    expect(store.pathExists('/foo', RegExp('/foo')), isTrue);
    expect(store.pathExists('/foo', RegExp('/bar')), isFalse);

    // Match with null query params (matches all query params)
    expect(
      store.pathExists(
        Uri(
          path: '/foo',
          queryParameters: {'bar': 'foobar'},
        ).toString(),
        RegExp('/foo'),
        queryParams: null,
      ),
      isTrue,
    );

    // Match with null value query param (matches key with any value)
    expect(
      store.pathExists(
        Uri(
          path: '/foo',
          queryParameters: {'bar': 'foobar'},
        ).toString(),
        RegExp('/foo'),
        queryParams: {'bar': null},
      ),
      isTrue,
    );

    // Match with exact query params
    expect(
      store.pathExists(
        Uri(
          path: '/foo',
          queryParameters: {'bar': 'foobar'},
        ).toString(),
        RegExp('/foo'),
        queryParams: {'bar': 'foobar'},
      ),
      isTrue,
    );

    // No match on different query param value
    expect(
      store.pathExists(
        Uri(
          path: '/foo',
          queryParameters: {'bar': 'foobar'},
        ).toString(),
        RegExp('/foo'),
        queryParams: {'bar': 'baz'},
      ),
      isFalse,
    );

    // No match on query params with different values
    expect(
      store.pathExists(
        Uri(
          path: '/foo',
          queryParameters: {
            'bar': 'foo',
            'qux': 'bar',
          },
        ).toString(),
        RegExp('/foo'),
        queryParams: {
          'bar': 'foo',
          'qux': 'foo',
        },
      ),
      isFalse,
    );
  });
}
