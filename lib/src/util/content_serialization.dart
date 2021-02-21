import 'dart:convert';

import 'package:dio/dio.dart';

Future<List<int>> serializeContent(ResponseType type, dynamic content) async {
  switch (type) {
    case ResponseType.bytes:
      return content;
    case ResponseType.stream:
      return (await (content as Stream<List<int>>).toList()).expand((x) => x)
          as List<int>;
    case ResponseType.plain:
      return utf8.encode(content);
    case ResponseType.json:
      return utf8.encode(jsonEncode(content));
    default:
      throw UnsupportedError('Response type not supported : $type.');
  }
}

dynamic deserializeContent(ResponseType type, List<int> content) {
  switch (type) {
    case ResponseType.bytes:
      return content;
    case ResponseType.stream:
      return Stream<List<int>>.fromIterable([content]);
    case ResponseType.plain:
      return utf8.decode(content);
    case ResponseType.json:
      return jsonDecode(utf8.decode(content));
    default:
      throw UnsupportedError('Response type not supported : $type.');
  }
}
