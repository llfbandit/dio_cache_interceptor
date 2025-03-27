import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/extension/response_extension.dart';
import 'package:http_cache_core/http_cache_core.dart';

/// Wrapper on [BaseResponse] to deal with [Response]
class DioBaseResponse extends BaseResponse {
  final Response response;

  DioBaseResponse(this.response);

  @override
  Map<String, List<String>> get headers => response.headers.map;

  @override
  bool isAttachment() => response.isAttachment();

  @override
  Uri get requestUri => response.requestOptions.uri;

  @override
  int? get statusCode => response.statusCode;
}
