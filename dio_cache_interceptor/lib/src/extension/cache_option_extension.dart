import 'package:dio/dio.dart';
import 'package:http_cache_core/http_cache_core.dart';

// Key to retrieve options from request
const extraKey = '@cache_options@';

extension CacheOptionExtension on CacheOptions {
  Options toOptions() {
    return Options(extra: toExtra());
  }

  Map<String, dynamic> toExtra() {
    return {extraKey: this};
  }
}
