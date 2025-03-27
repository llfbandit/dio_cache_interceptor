import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/extension/request_extension.dart';
import 'package:http_cache_core/http_cache_core.dart';

/// Wrapper on [BaseRequest] to deal with [RequestOptions]
class DioBaseRequest extends BaseRequest {
  final RequestOptions request;

  DioBaseRequest(this.request);

  @override
  List<String>? headerValuesAsList(String header) {
    return request.headerValuesAsList(header);
  }

  @override
  void setHeader(String header, String? value) {
    if (value == null) {
      request.headers.remove(header);
    } else {
      request.headers[header] = value;
    }
  }
}
