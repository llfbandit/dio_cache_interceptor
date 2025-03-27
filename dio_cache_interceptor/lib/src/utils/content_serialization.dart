import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

Future<List<int>?> serializeContent(ResponseType type, dynamic content) async {
  if (content == null) {
    return null;
  }

  return switch (type) {
    ResponseType.bytes => content,
    ResponseType.plain => utf8.encode(content),
    ResponseType.json => utf8.encode(jsonEncode(content)),
    _ => throw UnsupportedError('Response type not supported : $type.'),
  };
}

dynamic deserializeContent(ResponseType type, List<int>? content) {
  return switch (type) {
    ResponseType.bytes => content,
    ResponseType.plain => (content != null) ? utf8.decode(content) : null,
    ResponseType.json =>
      (content != null) ? jsonDecode(utf8.decode(content)) : null,
    _ => throw UnsupportedError('Response type not supported : $type.'),
  };
}
