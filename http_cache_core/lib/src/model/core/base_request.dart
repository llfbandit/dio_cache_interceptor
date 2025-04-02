/// Abtract request adapter
abstract class BaseRequest {
  /// Headers.
  Map<String, String> get headers;

  /// Applies a [value] if not null to the request's header or remove it otherwise.
  void setHeader(String header, String? value);
}
