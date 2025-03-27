import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

DatabaseConnection openDb({
  required String databasePath,
  required String databaseName,
  required String webSqlite3WasmPath,
  required String webDriftWorkerPath,
  bool logStatements = false,
}) {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: databaseName,
      sqlite3Uri: Uri.parse(webSqlite3WasmPath),
      driftWorkerUri: Uri.parse(webDriftWorkerPath),
    );

    return result.resolvedExecutor;
  }));
}
