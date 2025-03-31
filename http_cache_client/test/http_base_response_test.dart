import 'package:http/http.dart' as http;
import 'package:http_cache_client/src/model/http_base_response.dart';
import 'package:http_cache_core/http_cache_core.dart';
import 'package:test/test.dart';

void main() {
  test('headers returns null when no header value', () {
    final rq = http.Request('GET', Uri.parse('https://ok.org'));
    final response = HttpBaseResponse(http.Response('', 200, request: rq));

    expect(response.headers[cacheControlHeader], isNull);
  });

  test('status code returns status code', () {
    final rq = http.Request('GET', Uri.parse('https://ok.org'));
    final response = HttpBaseResponse(http.Response('', 200, request: rq));

    expect(response.statusCode, 200);
  });

  test('requestUri returns given request url', () {
    final rq = http.Request('GET', Uri.parse('https://ok.org'));
    final response = HttpBaseResponse(http.Response('', 200, request: rq));

    expect(response.requestUri, equals(rq.url));
  });

  test('isAttachment return false when not attachment', () {
    final rq = http.Request('GET', Uri.parse('https://ok.org'));

    expect(
      HttpBaseResponse(http.Response('', 200, request: rq)).isAttachment(),
      isFalse,
    );

    expect(
      HttpBaseResponse(http.Response('', 200,
          request: rq,
          headers: {'content-disposition': 'foo;bar,baz'})).isAttachment(),
      isFalse,
    );
  });

  test('isAttachment return true when attachment', () {
    final rq = http.Request('GET', Uri.parse('https://ok.org'));

    expect(
      HttpBaseResponse(http.Response('', 200,
          request: rq,
          headers: {'content-disposition': 'foo;attachment'})).isAttachment(),
      isTrue,
    );
  });
}
