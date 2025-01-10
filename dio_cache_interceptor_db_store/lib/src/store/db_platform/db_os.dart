import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

DatabaseConnection openDb({
  required String databasePath,
  required String databaseName,
  required String webSqlite3WasmPath,
  required String webDriftWorkerPath,
  bool logStatements = false,
}) {
  Directory(databasePath).createSync(recursive: true);
  final dbFile = File(p.join(databasePath, '$databaseName.db'));

  return NativeDatabase.createBackgroundConnection(
    dbFile,
    logStatements: logStatements,
  );
}
