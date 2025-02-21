import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_mmkv_store/src/store/cache_response_encoder.dart';
import 'package:mmkv/mmkv.dart';

class CacheResponseAdapteur {
  static MMBuffer? cacheResponseToMMBuffer(CacheResponse response) =>
      MMBuffer.fromList(response.toBytes());

  static CacheResponse? cacheResponseFromMMBuffer(MMBuffer buffer) {
    final bytes = buffer.asList();
    if (bytes == null) return null;
    return CacheResponseEncoder.cacheResponseFromBytes(bytes);
  }
}
