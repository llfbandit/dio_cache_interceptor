import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/extension/cache_option_extension.dart';
import 'package:http_cache_core/http_cache_core.dart';

extension RequestExtension on RequestOptions {
  CacheOptions? getCacheOptions() {
    return extra[extraKey];
  }

  /// Get headers flatten to String
  Map<String, String> getFlattenHeaders() {
    final h = <String, String>{};

    for (var header in headers.entries) {
      if (header.value is Iterable) {
        h[header.key] = header.value.join(', ');
      } else if (header.value != null) {
        h[header.key] = header.value.toString();
      }
    }

    return h;
  }
}
