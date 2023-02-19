import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';

void main(List<String> arguments) {
  // Full example is available at
  // https://github.com/llfbandit/dio_cache_interceptor/blob/master/dio_cache_interceptor/example/lib/main.dart

  late CacheStore cacheStore;

  getTemporaryDirectory().then((dir) {
    cacheStore = HiveCacheStore(dir.path);

    var cacheOptions = CacheOptions(
      store: cacheStore,
      hitCacheOnErrorExcept: [], // for offline behaviour
    );

    final dio = Dio()
      ..interceptors.add(
        DioCacheInterceptor(options: cacheOptions),
      );

    dio.get('https://www.foo.com');
  });
}
