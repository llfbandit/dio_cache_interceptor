import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'caller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CacheStore cacheStore;
  late CacheOptions cacheOptions;
  late Dio dio;
  late Caller caller;

  @override
  void initState() {
    cacheStore = MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576);
    cacheOptions = CacheOptions(
      store: cacheStore,
      hitCacheOnErrorExcept: [], // for offline behaviour
    );

    dio = Dio()
      ..interceptors.add(
        DioCacheInterceptor(options: cacheOptions),
      );

    // or

    // pp.getTemporaryDirectory().then((dir) {
    //   cacheStore = FileCacheStore(dir.path);

    //   // or

    //   cacheStore = DbCacheStore(databasePath: dir.path, logStatements: true);
    //   cacheStore = HiveCacheStore(dir.path);

    //   cacheOptions = CacheOptions(
    //     store: cacheStore,
    //     hitCacheOnErrorExcept: [], // for offline behaviour
    //   );

    //   dio = Dio()
    //     ..interceptors.add(
    //       DioCacheInterceptor(options: cacheOptions),
    //     );
    // });

    caller = Caller(
      cacheStore: cacheStore,
      cacheOptions: cacheOptions,
      dio: dio,
    );

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
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Dio cache interceptor'),
            bottom: TabBar(
              tabs: [
                Tab(
                    child: Text(
                  'With server cache',
                  textAlign: TextAlign.center,
                )),
                Tab(
                    child: Text(
                  'Without server cache',
                  textAlign: TextAlign.center,
                )),
                Tab(child: Text('Image')),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _WithCacheTab(caller),
              _WithoutCacheTab(caller),
              _ImageCacheTab(caller),
            ],
          ),
        ),
      ),
    );
  }
}

class _WithCacheTab extends StatefulWidget {
  const _WithCacheTab(this.caller);

  final Caller caller;

  @override
  _WithCacheTabState createState() => _WithCacheTabState();
}

class _WithCacheTabState extends State<_WithCacheTab> {
  String text = '';
  final url = 'https://www.wikipedia.org';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RaisedButton(
              onPressed: () async {
                final result = await widget.caller.cleanStore();
                setState(() => text = result);
              },
              child: Text('Clear store'),
            ),
            RaisedButton(
              onPressed: () async {
                final result = await widget.caller.deleteEntry(url);
                setState(() => text = result);
              },
              child: Text('Clear single entry'),
            ),
            RaisedButton(
              onPressed: () async {
                final result = await widget.caller.requestCall(url);
                setState(() => text = result);
              },
              child: Text('Call (Request policy)'),
            ),
            RaisedButton(
              onPressed: () async {
                final result = await widget.caller.refreshCall(url);
                setState(() => text = result);
              },
              child: Text('Call (Refresh policy)'),
            ),
            RaisedButton(
              onPressed: () async {
                final result = await widget.caller.noCacheCall(url);
                setState(() => text = result);
              },
              child: Text('Call (No cache policy)'),
            ),
            Text(text),
          ],
        ),
      ),
    );
  }
}

class _WithoutCacheTab extends StatefulWidget {
  const _WithoutCacheTab(this.caller);

  final Caller caller;

  @override
  _WithoutCacheTabState createState() => _WithoutCacheTabState();
}

class _WithoutCacheTabState extends State<_WithoutCacheTab> {
  String text = '';
  final url = 'https://pub.dev/packages/dio_cache_interceptor';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RaisedButton(
              onPressed: () async {
                final result = await widget.caller.cleanStore();
                setState(() => text = result);
              },
              child: Text('Clear store'),
            ),
            RaisedButton(
              onPressed: () async {
                final result = await widget.caller.deleteEntry(url);
                setState(() => text = result);
              },
              child: Text('Clear single entry'),
            ),
            RaisedButton(
              onPressed: () async {
                final result = await widget.caller.requestCall(url);
                setState(() => text = result);
              },
              child: Text('Call (Request policy)'),
            ),
            RaisedButton(
              onPressed: () async {
                final result = await widget.caller.forceCacheCall(url);
                setState(() => text = result);
              },
              child: Text('Call (forceCache policy)'),
            ),
            RaisedButton(
              onPressed: () async {
                final result = await widget.caller.refreshForceCacheCall(url);
                setState(() => text = result);
              },
              child: Text('Call (refreshForceCache policy)'),
            ),
            Text(text),
          ],
        ),
      ),
    );
  }
}

class _ImageCacheTab extends StatefulWidget {
  const _ImageCacheTab(this.caller);

  final Caller caller;

  @override
  _ImageCacheTabState createState() => _ImageCacheTabState();
}

class _ImageCacheTabState extends State<_ImageCacheTab> {
  final url =
      'https://fr.wikipedia.org/static/images/mobile/copyright/wikipedia.png';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Look at print output to get status code',
              textAlign: TextAlign.center,
            ),
            Image(image: DioImageProvider(url, widget.caller)),
          ],
        ),
      ),
    );
  }
}

/// Basic image downloader
/// Production implementation should use stream instead
/// to avoid OOM problems & improve performance
class DioImageProvider extends ImageProvider<DioImageProvider> {
  final String url;
  final Caller caller;

  const DioImageProvider(this.url, this.caller);

  @override
  ImageStreamCompleter load(DioImageProvider key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(decode),
      scale: 1.0,
    );
  }

  Future<Codec> _loadAsync(DecoderCallback decode) async {
    final response = await caller.dio.get<Uint8List>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    final bytes = response.data;
    if (bytes == null || bytes.length == 0) {
      throw StateError('$url cannot be loaded as an image.');
    }

    print(
      response.statusCode == 200
          ? 'From network ${response.statusCode}'
          : 'From cache ${response.statusCode}',
    );

    return decode(bytes);
  }

  @override
  Future<DioImageProvider> obtainKey(ImageConfiguration configuration) {
    // Force eviction of previously cached image by flutter framework
    // Without this line, load(...) isn't called again
    // This is only for testing purpose
    PaintingBinding.instance?.imageCache?.evict(this);

    return Future.value(this);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is DioImageProvider &&
        other.url == url &&
        other.caller == caller;
  }

  @override
  int get hashCode => url.hashCode ^ caller.hashCode;

  @override
  String toString() => '$DioImageProvider $url';
}
