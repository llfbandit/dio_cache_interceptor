import 'dart:io';

import 'package:http_cache_core/http_cache_core.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:http_cache_store_tester/common_store_testing.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  late FileCacheStore store;
  final dirPath = '${Directory.current.path}/test/data/file_store';

  setUpAll(() {
    store = FileCacheStore(dirPath);
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
    'Corrupted file',
    () async {
      await addFooResponse(store, key: 'corrupt');
      expect(await store.get('corrupt'), isNotNull);

      // corrupt file
      final file =
          File(path.join(dirPath, CachePriority.normal.name, 'corrupt'));
      if (!file.existsSync()) {
        throw Exception('Unexpected missing file.');
      }

      final bytes = file.readAsBytesSync();
      await file.writeAsBytes(bytes.sublist(0, bytes.length ~/ 2));

      expect(await store.get('corrupt'), isNull);
    },
  );

  test(
    'Concurrent access',
    () async => await concurrentAccess(store),
    timeout: Timeout(Duration(minutes: 2)),
  );
}
