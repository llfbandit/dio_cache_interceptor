import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as pp;

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
  late CacheStore cacheStore;
  late CacheOptions cacheOptions;
  late Dio dio;

  @override
  void initState() {
    pp.getApplicationDocumentsDirectory().then((dir) {
      cacheStore = FileCacheStore(dir.path);

      // or

      // cacheStore = DbCacheStore(databasePath: dir.path, logStatements: true);
      // cacheStore = HiveCacheStore(dir.path);

      cacheOptions = CacheOptions(
        store: cacheStore,
        hitCacheOnErrorExcept: [], // for offline demonstration
      );

      dio = Dio()
        ..interceptors.add(
          DioCacheInterceptor(options: cacheOptions),
        );
    });

    // or

    // cacheStore = MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576);
    // dio = Dio()
    //   ..interceptors.add(
    //     DioCacheInterceptor(options: CacheOptions(store: cacheStore)),
    //   );

    super.initState();
  }

  @override
  void dispose() async {
    dio.close();
    await cacheStore.close();
    return super.dispose();
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
                  onPressed: () async => await _requestCall(),
                  child: Text('Call (Request policy)'),
                ),
                RaisedButton(
                  onPressed: () async => await _refreshCall(),
                  child: Text('Call (Refresh policy)'),
                ),
                RaisedButton(
                  onPressed: () async => await _noCacheCall(),
                  child: Text('Call (No cache policy)'),
                ),
                Text(text),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _noCacheCall() async {
    final resp = await _call(policy: CachePolicy.noCache);
    if (resp == null) return;
    setState(() => text = _getResponseContent(resp));
  }

  Future _requestCall() async {
    final resp = await _call();
    if (resp == null) return;
    setState(() => text = _getResponseContent(resp));
  }

  Future _refreshCall() async {
    final resp = await _call(policy: CachePolicy.refresh);
    if (resp == null) return;
    setState(() => text = _getResponseContent(resp));
  }

  Future _deleteEntry() async {
    final key = CacheOptions.defaultCacheKeyBuilder(
      RequestOptions(path: 'https://www.wikipedia.org'),
    );
    await cacheStore.delete(key);
    setState(() => text = 'Entry "https://www.wikipedia.org" cleared');
  }

  Future _cleanStore() async {
    await cacheStore.clean();
    setState(() => text = 'Store cleared completely');
  }

  Future<Response> _call({
    String url = 'https://www.wikipedia.org',
    CachePolicy? policy,
  }) async {
    Options? options;
    options = cacheOptions.copyWith(policy: policy).toOptions();

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
