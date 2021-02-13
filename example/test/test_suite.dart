import 'package:flutter_test/flutter_test.dart';

import 'db_cache_store_test.dart' as db;
import 'file_cache_store_test.dart' as file;
import 'mem_cache_store_test.dart' as mem;
import 'backup_cache_store_test.dart' as backup;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  db.main();
  file.main();
  mem.main();
  backup.main();
}
