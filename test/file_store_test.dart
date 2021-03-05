import 'dart:io';

import 'package:dio_cache_interceptor/src/store/file_cache_store.dart';
import 'package:test/test.dart';

import 'common_store_testing.dart';

void main() {
  late FileCacheStore store;

  setUp(() async {
    store = FileCacheStore('${Directory.current.path}/test/data/file_store');
    await store.clean();
  });

  tearDown(() async {
    await store.close();
  });

  test('Empty by default', () async {
    await emptyByDefault(store);
  });

  test('Add item', () async {
    await addItem(store);
  });

  test('Get item', () async {
    await getItem(store);
  });

  test('Delete item', () async {
    await deleteItem(store);
  });

  test('Clean', () async {
    await clean(store);
  });
}
