import 'package:moor/moor_web.dart';

import '../database.dart';

DioCacheDatabase openDb({
  String databasePath,
  String databaseName,
  bool logStatements = false,
}) {
  return DioCacheDatabase(
    WebDatabase(databaseName, logStatements: logStatements),
  );
}
