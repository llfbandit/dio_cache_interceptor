import 'dart:io';

import 'package:dio_cache_interceptor_objectbox_store/dio_cache_interceptor_objectbox_store.dart';
import 'package:test/test.dart';

import '../../dio_cache_interceptor/test/common_store_testing.dart';

void main() {
  late ObjectBoxCacheStore store;

  setUp(() async {
    store = ObjectBoxCacheStore(storePath: Directory.current.path);
    await store.clean();
  });

  tearDown(() async {
    await store.close();
  });

  test('Empty by default', () async => await emptyByDefault(store));
  test('Add item', () async => await addItem(store));
  test('Get item', () async => await getItem(store));
  test('Delete item', () async => await deleteItem(store));
  test('Clean', () async => await clean(store));
  test('Expires', () async => await expires(store));
  test('LastModified', () async => await lastModified(store));
  test('Staled', () async => await staled(store));
}
