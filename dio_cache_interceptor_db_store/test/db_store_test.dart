import 'dart:ffi';
import 'dart:io';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_db_store/dio_cache_interceptor_db_store.dart';
import 'package:dio_cache_interceptor_db_store/src/store/database.dart';
import 'package:sqlite3/open.dart';
import 'package:test/test.dart';

import '../../dio_cache_interceptor/test/common_store_testing.dart';

void main() {
  late DbCacheStore store;

  DynamicLibrary _openOnWindows() {
    final libFile = File('${Directory.current.path}/test/lib/sqlite3.dll');
    return DynamicLibrary.open(libFile.path);
  }

  setUp(() async {
    open.overrideFor(OperatingSystem.windows, _openOnWindows);
    store = DbCacheStore(databasePath: '${Directory.current.path}/test/data');
    await store.clean();
  });

  tearDown(() async {
    await store.close();
  });

  test('DioCacheData toJson', () {
    // toJson is not used, force using it to virtually boost coverage
    final now = DateTime.now();

    final cacheData = DioCacheData(
      cacheKey: 'foo',
      priority: CachePriority.normal.index,
      responseDate: now,
      url: 'https://foo.com',
    );

    final map = cacheData.toJson();

    expect(map['cacheKey'], equals('foo'));
    expect(map['priority'], equals(CachePriority.normal.index));
    expect(map['responseDate'], equals(now.millisecondsSinceEpoch));
    expect(map['url'], equals('https://foo.com'));
  });

  test('Empty by default', () async => await emptyByDefault(store));
  test('Add item', () async => await addItem(store));
  test('Get item', () async => await getItem(store));
  test('Delete item', () async => await deleteItem(store));
  test('Clean', () async => await clean(store));
  test('Expires', () async => await expires(store));
  test('LastModified', () async => await lastModified(store));
}
