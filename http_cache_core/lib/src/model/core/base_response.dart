/// Abtract response adapter
abstract class BaseResponse {
  /// request URI
  Uri get requestUri;

  /// Response status code
  int? get statusCode;

  /// Headers for the response.
  Map<String, List<String>> get headers;

  /// Checks if Content-Disposition header of the response is attachment
  bool isAttachment();
}
