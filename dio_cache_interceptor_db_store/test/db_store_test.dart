import 'dart:io';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_db_store/dio_cache_interceptor_db_store.dart';
import 'package:dio_cache_interceptor_db_store/src/store/database.dart';
import 'package:test/test.dart';

import '../../dio_cache_interceptor/test/common_store_testing.dart';
import 'tool/download_sqlite.dart';

void main() {
  late DbCacheStore store;

  setUpAll(() async {
    // sqlite3 overrideFor doesn't seem to work with createBackgroundConnection
    // DL SQLite from official site
    await downloadSqlite();
    // Workaround sqlite3.open by copying lib in root project folder.
    // We can't remove the lib while it's being loaded by the VM.
    useLocalSqlite();

    store = DbCacheStore(databasePath: '${Directory.current.path}/test/data');
  });

  setUp(() async {
    await store.clean();
  });

  tearDownAll(() async {
    await store.close();
  });

  test('DioCacheData toJson', () {
    // toJson is not used, force using it to virtually boost coverage
    final now = DateTime.now();

    final cacheData = DioCacheData(
      cacheKey: 'foo',
      priority: CachePriority.normal.index,
      requestDate: now,
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
  test('pathExists', () => pathExists(store));
  test('deleteFromPath', () => deleteFromPath(store));
  test('getFromPath', () => getFromPath(store));
}
