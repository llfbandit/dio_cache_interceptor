import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart' as pp;

import './common_store_test.dart' as common;

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dir = await pp.getApplicationDocumentsDirectory();

  final dbCacheStore = DbCacheStore(databasePath: dir.path);
  final fileCacheStore = FileCacheStore(dir);
  final memCacheStore = MemCacheStore();
  final backupCacheStore = BackupCacheStore(
    primary: memCacheStore,
    secondary: dbCacheStore,
  );

  common.testStore('DB store tests', dbCacheStore);
  common.testStore('File store tests', fileCacheStore);
  common.testStore('Mem store tests', memCacheStore);
  common.testStore('Backup store tests', backupCacheStore);
}
