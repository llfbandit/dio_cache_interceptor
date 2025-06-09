import 'package:http_cache_mmkv_store/http_cache_mmkv_store.dart';
import 'package:test/test.dart';
import 'package:http_cache_store_tester/common_store_testing.dart';

import 'fake/mmkv_fake.dart';

void main() async {
  late MMKVCacheStore store;

  setUpAll(() async {
    store = MMKVCacheStore.fromMMKV(MMKVFake());
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
