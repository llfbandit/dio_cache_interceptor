import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text = '';
  CacheStore cacheStore;
  Dio dio;

  @override
  void initState() {
    cacheStore = DbCacheStore();
    // cacheStore = MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576);
    dio = Dio()
      ..interceptors.add(
        DioCacheInterceptor(options: CacheOptions(store: cacheStore)),
      );

    // or

    // getApplicationSupportDirectory().then((dir) {
    //   cacheStore = FileCacheStore(dir);

    //   dio = Dio()
    //     ..interceptors.add(
    //       DioCacheInterceptor(options: CacheOptions(store: cacheStore)),
    //     );
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dio cache interceptor',
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RaisedButton(
                  onPressed: () async => await _cleanStore(),
                  child: Text('Clear store'),
                ),
                RaisedButton(
                  onPressed: () async => await _deleteEntry(),
                  child: Text('Clear single entry'),
                ),
                RaisedButton(
                  onPressed: () async => await _requestFirstCall(),
                  child: Text('Call (Request first policy)'),
                ),
                RaisedButton(
                  onPressed: () async => await _refreshCall(),
                  child: Text('Call (Refresh policy)'),
                ),
                RaisedButton(
                  onPressed: () async => await _cacheFirstCall(),
                  child: Text('Call (Cache first policy)'),
                ),
                RaisedButton(
                  onPressed: () async => await _cacheStoreNoCall(),
                  child: Text('Call (Cache store no policy)'),
                ),
                Text(text),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _cacheStoreNoCall() async {
    final resp = await _call(policy: CachePolicy.cacheStoreNo);
    if (resp == null) return;
    setState(() => text = _getResponseContent(resp));
  }

  Future _requestFirstCall() async {
    final resp = await _call();
    if (resp == null) return;
    setState(() => text = _getResponseContent(resp));
  }

  Future _refreshCall() async {
    final resp = await _call(policy: CachePolicy.refresh);
    if (resp == null) return;
    setState(() => text = _getResponseContent(resp));
  }

  Future _cacheFirstCall() async {
    final resp = await _call(policy: CachePolicy.cacheFirst);
    if (resp == null) return;
    setState(() => text = _getResponseContent(resp));
  }

  Future _deleteEntry() async {
    final key = CacheOptions.defaultCacheKeyBuilder(
      RequestOptions(path: 'http://www.wikipedia.org'),
    );
    await cacheStore.delete(key);
    setState(() => text = 'Entry "http://www.wikipedia.org" cleared');
  }

  Future _cleanStore() async {
    await cacheStore.clean();
    setState(() => text = 'Store cleared completely');
  }

  Future<Response> _call({
    String url = 'http://www.wikipedia.org',
    CachePolicy policy,
  }) async {
    Options options;
    if (policy != null) {
      options = CacheOptions(store: cacheStore, policy: policy).toOptions();
    }

    try {
      return await dio.get(url, options: options);
    } on DioError catch (err) {
      setState(() => text = err.toString());
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
    buffer.writeln('${response.request.headers.toString()}\n');

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
