import 'package:flutter_test/flutter_test.dart';

import 'db_cache_store_test.dart' as dbStoreTest;
import 'file_cache_store_test.dart' as fileStoreTest;
import 'mem_cache_store_test.dart' as memStoreTest;
import 'backup_cache_store_test.dart' as backupStoreTest;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  dbStoreTest.main();
  fileStoreTest.main();
  memStoreTest.main();
  backupStoreTest.main();
}
