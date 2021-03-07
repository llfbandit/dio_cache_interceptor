import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:path/path.dart' as p;

import '../database.dart';

DioCacheDatabase openDb({
  required String databasePath,
  required String databaseName,
  bool logStatements = false,
}) {
  Directory(databasePath).createSync(recursive: true);
  final dbFile = File(p.join(databasePath, '$databaseName.db'));

  return DioCacheDatabase(
    VmDatabase(dbFile, logStatements: logStatements),
  );
}
