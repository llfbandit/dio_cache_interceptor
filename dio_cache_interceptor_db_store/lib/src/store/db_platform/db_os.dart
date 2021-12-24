import 'dart:io';

import 'package:drift/native.dart';
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
    NativeDatabase(dbFile, logStatements: logStatements),
  );
}
