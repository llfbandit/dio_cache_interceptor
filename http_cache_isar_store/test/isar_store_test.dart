import 'dart:io';

import 'package:http_cache_isar_store/http_cache_isar_store.dart';
import 'package:http_cache_store_tester/common_store_testing.dart';
import 'package:isar/isar.dart';
import 'package:test/test.dart';

void main() {
  late IsarCacheStore store;

  setUpAll(() async {
    store = IsarCacheStore('${Directory.current.path}/test');
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    await store.clean();
  });

  tearDownAll(() async {
    await store.close();
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
  test(
    'Concurrent access',
    () async => await concurrentAccess(store),
    timeout: Timeout(Duration(minutes: 2)),
  );
}
