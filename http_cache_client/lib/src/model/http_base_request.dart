import 'package:http/http.dart' as http;
import 'package:http_cache_core/http_cache_core.dart';

class HttpBaseRequest extends BaseRequest {
  final http.BaseRequest inner;
  final CacheOptions options;
  final DateTime _date;

  HttpBaseRequest(this.inner, this.options, this._date);

  @override
  List<String>? headerValuesAsList(String header) {
    final value = inner.headers[header];

    if (value != null) {
      final values = <String>[];

      if (!value.contains(',')) {
        values.add(value);
      } else {
        if (header == 'set-cookie') {
          return value.split(setCookieSplitter);
        } else {
          return value.split(headerSplitter);
        }
      }

      return values;
    }

    return null;
  }

  @override
  void setHeader(String header, String? value) {
    if (value == null) {
      inner.headers.remove(header);
    } else {
      inner.headers[header] = value;
    }
  }

  DateTime get requestDate => _date;
}
