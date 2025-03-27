import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;

const _version = '3390300';
const _year = '2022';
const _url = 'https://www.sqlite.org/$_year/sqlite-autoconf-$_version.tar.gz';

String? get expectedSqlite3LibName {
  if (Platform.isWindows) {
    return 'sqlite3.dll';
  } else if (Platform.isMacOS) {
    return 'libsqlite3.dylib';
  } else if (Platform.isLinux) {
    return 'libsqlite3.so';
  } else {
    return null;
  }
}

String? get expectedLocalSqlite3Path {
  return p.join('.dart_tool', 'sqlite3', expectedSqlite3LibName);
}

void useLocalSqlite() {
  final path = expectedLocalSqlite3Path;
  if (path == null) return;

  final libFile = File(path);

  if (libFile.existsSync()) {
    libFile.copySync(p.join(Directory.current.path, expectedSqlite3LibName));
  }
}

Future<void> downloadSqlite() async {
  final target = p.join('.dart_tool', 'sqlite3');
  final versionFile = File(p.join(target, 'version'));

  final needsDownload =
      !versionFile.existsSync() || versionFile.readAsStringSync() != _version;

  if (!needsDownload) {
    print('Not doing anything as sqlite3 has already been downloaded.');
    return;
  }

  print('Downloading and compiling sqlite3 for drift test');

  final temporaryDir =
      await Directory.systemTemp.createTemp('drift-compile-sqlite3');
  final temporaryDirPath = temporaryDir.path;

  if (Platform.isWindows) {
    // Compiling on Windows is ugly because we need users to have Visual Studio
    // installed and all those tools activated in the current shell.
    // Much easier to just download precompiled builds.
    await _downloadForWindows(
      temporaryDirPath: temporaryDirPath,
      target: target,
    );
  } else {
    await _downloadForNix(temporaryDirPath: temporaryDirPath, target: target);
  }
}

Future<void> _downloadForWindows({
  required String temporaryDirPath,
  required String target,
}) async {
  const windowsUri =
      'https://www.sqlite.org/$_year/sqlite-dll-win64-x64-$_version.zip';
  final sqlite3Zip = p.join(temporaryDirPath, 'sqlite3.zip');
  final client = Client();
  final response = await client.send(Request('GET', Uri.parse(windowsUri)));
  if (response.statusCode != 200) {
    print('Could not download $windowsUri, status code ${response.statusCode}');
    return;
  }
  await response.stream.pipe(File(sqlite3Zip).openWrite());

  final inputStream = InputFileStream(sqlite3Zip);
  final archive = ZipDecoder().decodeBuffer(inputStream);

  for (final file in archive.files) {
    if (file.isFile && file.name == 'sqlite3.dll') {
      final outputStream = OutputFileStream(p.join(target, 'sqlite3.dll'));

      file.writeContent(outputStream);
      outputStream.close();
    }
  }

  await File(p.join(target, 'version')).writeAsString(_version);
}

Future<void> _downloadForNix({
  required String temporaryDirPath,
  required String target,
}) async {
  if (Platform.isLinux) return;

  await _run('curl $_url --output sqlite.tar.gz',
      workingDirectory: temporaryDirPath);
  await _run('tar zxvf sqlite.tar.gz', workingDirectory: temporaryDirPath);

  final sqlitePath = p.join(temporaryDirPath, 'sqlite-autoconf-$_version');
  await _run('./configure', workingDirectory: sqlitePath);
  await _run('make -j', workingDirectory: sqlitePath);

  final targetDirectory = Directory(target);

  if (!targetDirectory.existsSync()) {
    // Not using recursive since .dart_tool should really exist already.
    targetDirectory.createSync();
  }

  await File(p.join(sqlitePath, 'sqlite3')).copy(p.join(target, 'sqlite3'));

  if (Platform.isLinux) {
    await File(p.join(sqlitePath, '.libs', 'libsqlite3.so')).copy(
      p.join(target, 'libsqlite3.so'),
    );
  } else if (Platform.isMacOS) {
    await File(p.join(sqlitePath, '.libs', 'libsqlite3.dylib')).copy(
      p.join(target, 'libsqlite3.dylib'),
    );
  }

  await File(p.join(target, 'version')).writeAsString(_version);
}

Future<void> _run(String command, {String? workingDirectory}) async {
  print('Running $command');

  final proc = await Process.start(
    'sh',
    ['-c', command],
    mode: ProcessStartMode.inheritStdio,
    workingDirectory: workingDirectory,
  );
  final exitCode = await proc.exitCode;

  if (exitCode != 0) {
    exit(exitCode);
  }
}
