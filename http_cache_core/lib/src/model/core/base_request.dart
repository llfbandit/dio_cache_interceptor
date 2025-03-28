/// Abtract request adapter
abstract class BaseRequest {
  /// Header values as list for a given header key..
  List<String>? headerValuesAsList(String header);

  /// Applies a [value] if not null to the request's header or remove it otherwise.
  void setHeader(String header, String? value);
}
