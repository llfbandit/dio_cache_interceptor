import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'dart:io';

class Caller {
  const Caller({
    required this.cacheStore,
    required this.cacheOptions,
    required this.dio,
  });

  final CacheStore cacheStore;
  final CacheOptions cacheOptions;
  final Dio dio;

  Future<String> noCacheCall(String url) async {
    final resp = await _call(url: url, policy: CachePolicy.noCache);
    if (resp == null) return 'No response';
    return _getResponseContent(resp);
  }

  Future<String> requestCall(String url) async {
    final resp = await _call(url: url);
    if (resp == null) return 'No response';
    return _getResponseContent(resp);
  }

  Future<String> refreshCall(String url) async {
    final resp = await _call(url: url, policy: CachePolicy.refresh);
    if (resp == null) return 'No response';
    return _getResponseContent(resp);
  }

  Future<String> forceCacheCall(String url) async {
    final resp = await _call(url: url, policy: CachePolicy.forceCache);
    if (resp == null) return 'No response';
    return _getResponseContent(resp);
  }

  Future<String> refreshForceCacheCall(String url) async {
    final resp = await _call(url: url, policy: CachePolicy.refreshForceCache);
    if (resp == null) return 'No response';
    return _getResponseContent(resp);
  }

  Future<String> deleteEntry(String url) async {
    final key = CacheOptions.defaultCacheKeyBuilder(
      RequestOptions(path: url),
    );
    await cacheStore.delete(key);
    return 'Entry "$url" cleared';
  }

  Future<String> cleanStore() async {
    await cacheStore.clean();
    return 'Store cleared completely';
  }

  Future<Response?> _call({
    required String url,
    CachePolicy? policy,
  }) {
    Options? options;
    options = cacheOptions.copyWith(policy: policy).toOptions();

    try {
      return dio.get(url, options: options);
    } on DioError catch (err) {
      return Future.value(null);
    }
  }

  String _getResponseContent(Response response) {
    final date = response.headers[HttpHeaders.dateHeader]?.first;
    final etag = response.headers[HttpHeaders.etagHeader]?.first;
    final expires = response.headers[HttpHeaders.expiresHeader]?.first;
    final lastModified =
        response.headers[HttpHeaders.lastModifiedHeader]?.first;
    final cacheControl =
        response.headers[HttpHeaders.cacheControlHeader]?.first;

    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln('Call returned ${response.statusCode}\n');

    buffer.writeln('Request headers:');
    buffer.writeln('${response.requestOptions.headers.toString()}\n');

    buffer.writeln('Response headers (cache related):');
    if (date != null) {
      buffer.writeln('${HttpHeaders.dateHeader}: $date');
    }
    if (etag != null) {
      buffer.writeln('${HttpHeaders.etagHeader}: $etag');
    }
    if (expires != null) {
      buffer.writeln('${HttpHeaders.expiresHeader}: $expires');
    }
    if (lastModified != null) {
      buffer.writeln('${HttpHeaders.lastModifiedHeader}: $lastModified');
    }
    if (cacheControl != null) {
      buffer.writeln('${HttpHeaders.cacheControlHeader}: $cacheControl');
    }

    buffer.writeln('');
    buffer.writeln('Response body (truncated):');
    buffer.writeln('${response.data.toString().substring(0, 200)}...');

    return buffer.toString();
  }
}
