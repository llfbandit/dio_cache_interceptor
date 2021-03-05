import 'dart:ffi';
import 'dart:io';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:sqlite3/open.dart';
import 'package:test/test.dart';

import 'common_store_testing.dart';

void main() {
  late DbCacheStore store;

  // DynamicLibrary _openOnLinux() {
  //   final libFile = File('${Directory.current.path}/test/lib/libsqlite3.so');
  //   return DynamicLibrary.open(libFile.path);
  // }

  DynamicLibrary _openOnWindows() {
    final libFile = File('${Directory.current.path}/test/lib/sqlite3.dll');
    return DynamicLibrary.open(libFile.path);
  }

  setUp(() async {
    // open.overrideFor(OperatingSystem.linux, _openOnLinux);
    open.overrideFor(OperatingSystem.windows, _openOnWindows);
    store = DbCacheStore(databasePath: '${Directory.current.path}/test/data');
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
