import 'dart:io';

import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:test/test.dart';

import '../../dio_cache_interceptor/test/common_store_testing.dart';

void main() {
  late HiveCacheStore store;

  setUpAll(() {
    store = HiveCacheStore('${Directory.current.path}/test/data/file_store');
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
}
