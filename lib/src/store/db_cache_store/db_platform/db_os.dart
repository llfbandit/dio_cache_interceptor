import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';

import 'package:path/path.dart' as p;

import '../database.dart';

DioCacheDatabase openDb({
  required String databasePath,
  required String databaseName,
  bool logStatements = false,
}) {
  Directory(databasePath).createSync(recursive: true);
  final dbFile = File(p.join(databasePath, '$databaseName.db'));

  if (Platform.isIOS || Platform.isAndroid) {
    final executor = LazyDatabase(() async {
      return VmDatabase(dbFile, logStatements: logStatements);
    });
    return DioCacheDatabase(executor);
  }

  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    return DioCacheDatabase(
      VmDatabase(dbFile, logStatements: logStatements),
    );
  }

  return DioCacheDatabase(
    VmDatabase.memory(logStatements: logStatements),
  );
}
