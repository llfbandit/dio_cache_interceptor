import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/extension/cache_option_extension.dart';
import 'package:http_cache_core/http_cache_core.dart';

extension RequestExtension on RequestOptions {
  // Request headers are not of type Headers...
  // This method helps to wrap it to correct list for iteration
  List<String>? headerValuesAsList(String headerKey) {
    final value = headers[headerKey];

    if (value is List<String>) return value;
    if (value is String) return value.split(',').map((h) => h.trim()).toList();

    return value;
  }

  CacheOptions? getCacheOptions() {
    return extra[extraKey];
  }
}
