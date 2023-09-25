import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/src/util/content_serialization.dart';
import 'package:test/test.dart';

void main() {
  test('Serialize bytes', () async {
    final content = 'test'.codeUnits;

    final serializedContent = await serializeContent(
      ResponseType.bytes,
      content,
    );
    final deserializedContent = await deserializeContent(
      ResponseType.bytes,
      serializedContent,
    );
    expect(deserializedContent, equals(content));
  });

  test('Unsupported stream', () async {
    Stream<List<int>> content() async* {
      yield 'test'.codeUnits;
    }

    expect(() async => await serializeContent(ResponseType.stream, content()),
        throwsUnsupportedError);
    expect(() async => await deserializeContent(ResponseType.stream, <int>[]),
        throwsUnsupportedError);
  });

  test('Serialize plain', () async {
    final content = 'test';

    final serializedContent = await serializeContent(
      ResponseType.plain,
      content,
    );
    final deserializedContent = await deserializeContent(
      ResponseType.plain,
      serializedContent,
    );
    expect(deserializedContent, equals(content));
  });

  test('Serialize json', () async {
    final content = {'test': 'value'};

    final serializedContent = await serializeContent(
      ResponseType.json,
      content,
    );
    final deserializedContent = await deserializeContent(
      ResponseType.json,
      serializedContent,
    );
    expect(deserializedContent, equals(content));
  });

  test('Serialize null', () async {
    final serializedContent = await serializeContent(
      ResponseType.json,
      null,
    );
    final deserializedContent = await deserializeContent(
      ResponseType.json,
      serializedContent,
    );

    expect(deserializedContent, isNull);
  });
}
