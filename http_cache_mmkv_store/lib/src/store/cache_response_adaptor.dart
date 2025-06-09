import 'package:http_cache_mmkv_store/src/store/cache_response_encoder.dart';
import 'package:mmkv/mmkv.dart';
import 'package:http_cache_core/http_cache_core.dart';

class CacheResponseAdaptor {
  static MMBuffer? cacheResponseToMMBuffer(CacheResponse response) =>
      MMBuffer.fromList(response.toBytes());

  static CacheResponse? cacheResponseFromMMBuffer(MMBuffer buffer) {
    final bytes = buffer.asList();
    if (bytes == null) return null;
    return CacheResponseEncoder.cacheResponseFromBytes(bytes);
  }
}
