import 'package:http/http.dart' as http;
import 'package:http_cache_core/http_cache_core.dart';

class HttpBaseResponse extends BaseResponse {
  final http.Response response;

  HttpBaseResponse(this.response);

  @override
  Map<String, List<String>> get headers => response.headersSplitValues;

  @override
  bool isAttachment() => _isAttachment();

  @override
  Uri get requestUri => response.request!.url;

  @override
  int? get statusCode => response.statusCode;

  /// Checks if disposition of the response is attachment
  /// or response type is stream since content-disposition can be missing
  /// when simply calling dio.download method.
  bool _isAttachment() {
    final disposition = headers['content-disposition'];

    if (disposition != null) {
      for (final value in disposition) {
        for (final expandedValue in value.split(';')) {
          if (expandedValue.trim().toLowerCase().contains('attachment')) {
            return true;
          }
        }
      }
    }

    return false;
  }
}
