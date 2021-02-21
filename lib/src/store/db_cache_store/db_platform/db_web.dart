import 'package:meta/meta.dart';
import 'package:moor/moor_web.dart';

import '../database.dart';

DioCacheDatabase openDb({
  @required String databasePath,
  String databaseName,
  bool logStatements = false,
}) {
  return DioCacheDatabase(
    WebDatabase(databaseName, logStatements: logStatements),
  );
}
