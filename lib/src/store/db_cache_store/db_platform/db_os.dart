import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';

import 'package:path_provider/path_provider.dart' as pp;
import 'package:path/path.dart' as p;

import '../database.dart';

DioCacheDatabase openDb({
  String databasePath,
  String databaseName,
  bool logStatements = false,
}) {
  if (Platform.isIOS || Platform.isAndroid) {
    final executor = LazyDatabase(() async {
      final path =
          databasePath ?? (await pp.getApplicationDocumentsDirectory()).path;
      await Directory(path).create(recursive: true);
      final dbFile = File(p.join(path, '$databaseName.db'));

      return VmDatabase(dbFile, logStatements: logStatements);
    });
    return DioCacheDatabase(executor);
  }

  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    final dbFile = File(p.join(databasePath ?? '', '$databaseName.db'));
    return DioCacheDatabase(
      VmDatabase(dbFile, logStatements: logStatements),
    );
  }

  return DioCacheDatabase(
    VmDatabase.memory(logStatements: logStatements),
  );
}
