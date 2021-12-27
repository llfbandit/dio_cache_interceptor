import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:test/test.dart';

void main() {
  test('enum short string', () {
    expect('high', CachePriority.high.toShortString());
    expect('low', CachePriority.low.toShortString());
    expect('normal', CachePriority.normal.toShortString());
  });
}
