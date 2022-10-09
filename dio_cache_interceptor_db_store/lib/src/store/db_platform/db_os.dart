import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../database.dart';

DioCacheDatabase openDb({
  required String databasePath,
  required String databaseName,
  bool logStatements = false,
}) {
  Directory(databasePath).createSync(recursive: true);
  final dbFullPath = p.join(databasePath, '$databaseName.db');

  return DioCacheDatabase.connect(
    DatabaseConnection.delayed(
      Future(() async {
        final isolate = await _createDriftIsolate(dbFullPath);
        return isolate.connect();
      }),
    ),
  );
}

Future<DriftIsolate> _createDriftIsolate(String path) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(
    _startBackground,
    _DriftIsolateData(receivePort.sendPort, path),
  );

  return await receivePort.first as DriftIsolate;
}

void _startBackground(_DriftIsolateData data) {
  final executor = NativeDatabase(File(data.path));
  final driftIsolate = DriftIsolate.inCurrent(
    () => DatabaseConnection(executor),
  );
  data.port.send(driftIsolate);
}

class _DriftIsolateData {
  _DriftIsolateData(this.port, this.path);

  final SendPort port;
  final String path;
}
