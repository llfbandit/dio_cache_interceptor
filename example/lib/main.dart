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
    // cacheStore = MemCacheStore();
    dio = Dio()
      ..interceptors.add(
        DioCacheInterceptor(options: CacheOptions(store: cacheStore)),
      );
    //
    // or
    //
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
                  onPressed: () async => await _cacheFirstCall(),
                  child: Text('Cache first call'),
                ),
                RaisedButton(
                  onPressed: () async => await _refreshCall(),
                  child: Text('Refresh call'),
                ),
                RaisedButton(
                  onPressed: () async => await _requestFirstCall(),
                  child: Text('Request first call'),
                ),
                RaisedButton(
                  onPressed: () async => await _cacheStoreNoCall(),
                  child: Text('Cache store no call'),
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
    var resp = await _call(policy: CachePolicy.cacheStoreNo);
    setState(() => text = _getResponseContent(resp));
  }

  Future _requestFirstCall() async {
    var resp = await _call();
    setState(() => text = _getResponseContent(resp));
  }

  Future _refreshCall() async {
    var resp = await _call(policy: CachePolicy.refresh);
    setState(() => text = _getResponseContent(resp));
  }

  Future _cacheFirstCall() async {
    var resp = await _call(policy: CachePolicy.cacheFirst);
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
    setState(() => text = 'Store cleared');
  }

  Future<Response> _call({
    String url = 'http://www.wikipedia.org',
    CachePolicy policy,
  }) async {
    Options options;
    if (policy != null) {
      options = CacheOptions(store: cacheStore, policy: policy).toOptions();
    }

    return dio.get(url, options: options);
  }

  String _getResponseContent(Response response) {
    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln('Call returned ${response.statusCode}');
    buffer.writeln('Request headers:');
    buffer.writeln('${response.request.headers.toString()}');
    buffer.writeln('');
    buffer.writeln('Response headers (truncated):');
    buffer.writeln('${response.headers.toString().substring(0, 200)}...');
    buffer.writeln('');
    buffer.writeln('Response body (truncated):');
    buffer.writeln('${response.data.toString().substring(0, 200)}...');

    return buffer.toString();
  }
}
