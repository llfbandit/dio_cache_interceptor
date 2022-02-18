import 'package:dio/dio.dart';

extension RequestExtension on RequestOptions {
  // Request headers are not of type Headers...
  // This method helps to wrap it to correct list for iteration
  List<String>? headerValuesAsList(String headerKey) {
    final value = headers[headerKey];

    if (value is List<String>) return value;
    if (value is String) return value.split(',');

    return value;
  }
}
