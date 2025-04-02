import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

void main() {
  test('Default headers', () {
    final cacheControl1 = CacheControl();
    expect(cacheControl1.maxAge, equals(-1));
    expect(cacheControl1.noCache, false);
    expect(cacheControl1.noStore, false);
    expect(cacheControl1.other, equals([]));
    expect(cacheControl1.privacy, isNull);
    expect(cacheControl1.maxStale, equals(-1));
    expect(cacheControl1.minFresh, equals(-1));
    expect(cacheControl1.mustRevalidate, equals(false));

    expect(cacheControl1, equals(CacheControl.fromHeader(null)));
    expect(cacheControl1, equals(CacheControl.fromHeader([])));
  });

  test('headers', () {
    final cacheControl1 = CacheControl(
      maxAge: 1,
      noCache: true,
      noStore: true,
      other: ['unknown', 'unknown2=2'],
      privacy: 'public',
      maxStale: 2,
      minFresh: 3,
      mustRevalidate: true,
    );

    final cacheControl2 = CacheControl.fromHeader([
      'max-age=1, no-store, no-cache, public, unknown, unknown2=2, max-stale=2, min-fresh=3, must-revalidate',
    ]);

    expect(cacheControl1, equals(cacheControl2));

    // Redo test with toHeader()
    final cacheControl3 = CacheControl.fromHeader([cacheControl2.toHeader()]);
    expect(cacheControl1, equals(cacheControl3));
  });

  test('headers splitted', () {
    final cacheControl1 = CacheControl(
      maxAge: 1,
      noCache: true,
      noStore: true,
      privacy: 'public',
      maxStale: 2,
      minFresh: 3,
      mustRevalidate: true,
    );

    final cacheControl2 = CacheControl.fromHeader([
      'max-age=1',
      'no-store',
      'no-cache',
      'public',
      'max-stale=2',
      'min-fresh=3',
      'must-revalidate',
    ]);

    expect(cacheControl1, equals(cacheControl2));

    // Redo test with toHeader()
    final cacheControl3 = CacheControl.fromHeader([cacheControl2.toHeader()]);
    expect(cacheControl1, equals(cacheControl3));
  });

  test('CacheControl.fromString', () {
    final cacheControl1 = CacheControl(
      maxAge: 1,
      noCache: true,
      noStore: true,
      privacy: 'public',
      maxStale: 2,
      minFresh: 3,
      mustRevalidate: true,
    );

    final cacheControl2 = CacheControl.fromString([
      'max-age=1',
      'no-store',
      'no-cache="set-cookie"', // no-cache is detected but set-cookie is lost
      'public',
      'max-stale=2',
      'min-fresh=3',
      'must-revalidate',
    ].join(', '));

    expect(cacheControl1, equals(cacheControl2));

    // Redo test with toHeader()
    final cacheControl3 = CacheControl.fromHeader([cacheControl2.toHeader()]);
    expect(cacheControl1, equals(cacheControl3));
  });
}
