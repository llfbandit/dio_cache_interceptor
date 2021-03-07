import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:test/test.dart';

void main() {
  test('isStale', () {
    var cacheControl = CacheControl();
    expect(cacheControl.isStale(DateTime.now(), null, null), isFalse);

    cacheControl = CacheControl(maxAge: 10);
    expect(
        cacheControl.isStale(
          DateTime.now(),
          DateTime.now().subtract(const Duration(seconds: 12)),
          null,
        ),
        isTrue);

    // max-age takes precedence over expires
    cacheControl = CacheControl(maxAge: 10);
    expect(
        cacheControl.isStale(
          DateTime.now(),
          DateTime.now().subtract(const Duration(seconds: 12)),
          DateTime.now().add(const Duration(hours: 10)),
        ),
        isTrue);

    // max-age is invalid check with expires
    cacheControl = CacheControl(maxAge: 0);
    expect(
        cacheControl.isStale(
          DateTime.now(),
          DateTime.now().subtract(const Duration(seconds: 12)),
          DateTime.now().add(const Duration(hours: 10)),
        ),
        isFalse);

    cacheControl = CacheControl();
    expect(
        cacheControl.isStale(
          DateTime.now(),
          null,
          DateTime.now().subtract(const Duration(hours: 10)),
        ),
        isTrue);
  });
}
