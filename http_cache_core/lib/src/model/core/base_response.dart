abstract class BaseResponse {
  Uri get requestUri;

  int? get statusCode;

  /// Headers for the response.
  Map<String, List<String>> get headers;

  bool isAttachment();
}
