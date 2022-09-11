import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:path/path.dart' as path;
import 'package:synchronized/synchronized.dart';

/// A store saving responses in a dedicated file from a given root [directory].
///
class FileCacheStore extends CacheStore {
  final Map<CachePriority, Directory> _directories;
  final Map<String, Lock> _locks = {};

  FileCacheStore(String directory) : _directories = _genDirectories(directory) {
    clean(staleOnly: true);
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    for (var index = 0; index <= priorityOrBelow.index; ++index) {
      final directory = _directories[CachePriority.values[index]]!;

      if (!await directory.exists()) continue;

      final fseList = directory.listSync(followLinks: false);
      for (final fse in fseList) {
        if (fse is File) {
          final key = path.basename(fse.path);

          await _synchronized(key, () async {
            await _deleteFile(fse, staleOnly: staleOnly);
          });
        }
      }
    }
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    return _synchronized(
      key,
      () async => _deleteFile(await _findFile(key), staleOnly: staleOnly),
    );
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final responses = await getFromPath(
      pathPattern,
      queryParams: queryParams,
    );

    for (final response in responses) {
      await delete(response.key);
    }
  }

  @override
  Future<bool> exists(String key) async {
    return _synchronized(key, () async => await _findFile(key) != null);
  }

  @override
  Future<CacheResponse?> get(String key) async {
    return _synchronized(key, () async {
      return _deserializeContent(await _findFile(key));
    });
  }

  @override
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final responses = <CacheResponse>[];

    for (final priority in CachePriority.values) {
      final directory = _directories[priority]!;

      if (!await directory.exists()) continue;

      final fseList = directory.listSync(followLinks: false);
      for (final fse in fseList) {
        if (fse is File) {
          final key = path.basename(fse.path);

          await _synchronized(key, () async {
            final resp = await _deserializeContent(fse);
            if (resp != null) {
              if (pathExists(resp.url, pathPattern, queryParams: queryParams)) {
                responses.add(resp);
              }
            }
          });
        }
      }
    }

    return responses;
  }

  @override
  Future<void> set(CacheResponse response) async {
    return _synchronized(response.key, () async {
      final file = File(
        path.join(
          _directories[response.priority]!.path,
          response.key,
        ),
      );

      // Delete previous value in case of priority change
      await _deleteFile(await _findFile(response.key), staleOnly: false);

      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }

      final bytes = _serializeContent(response);
      await file.writeAsBytes(bytes, mode: FileMode.writeOnly, flush: true);
    });
  }

  @override
  Future<void> close() {
    return Future.value();
  }

  Future<T> _synchronized<T>(
    String key,
    FutureOr<T> Function() computation,
  ) async {
    final lock = _locks.putIfAbsent(key, () => Lock(reentrant: true));

    final result = await lock.synchronized(() {
      final result = computation.call();
      return result;
    });

    _locks.remove(lock);

    return result;
  }

  List<int> _serializeContent(CacheResponse response) {
    final etag = utf8.encode(response.eTag ?? '');
    final lastModified = utf8.encode(response.lastModified ?? '');
    final maxStale = utf8.encode(
      response.maxStale?.millisecondsSinceEpoch.toString() ?? '',
    );
    final url = utf8.encode(response.url);
    final cacheControl = utf8.encode(response.cacheControl.toHeader());
    final date = utf8.encode(response.date?.toIso8601String() ?? '');
    final expires = utf8.encode(response.expires?.toIso8601String() ?? '');
    final requestDate = utf8.encode(response.requestDate.toIso8601String());
    final responseDate = utf8.encode(response.responseDate.toIso8601String());

    return [
      ...Int32List.fromList([
        response.content?.length ?? 0,
        etag.length,
        response.headers?.length ?? 0,
        lastModified.length,
        maxStale.length,
        url.length,
        cacheControl.length,
        date.length,
        expires.length,
        responseDate.length,
        requestDate.length,
      ]).buffer.asInt8List(),
      ...response.content ?? [],
      ...etag,
      ...response.headers ?? [],
      ...lastModified,
      ...maxStale,
      ...url,
      ...cacheControl,
      ...date,
      ...expires,
      ...responseDate,
      ...requestDate,
    ];
  }

  Future<CacheResponse?> _deserializeContent(File? file) async {
    if (file == null) return null;

    final data = await file.readAsBytes();

    try {
      // Get field sizes
      // 11 fields. int is encoded with 32 bits from Int8List
      var i = 11 * 4;
      final sizes = Int8List.fromList(
        data.take(i).toList(),
      ).buffer.asInt32List();

      var fieldIndex = 0;

      var size = sizes[fieldIndex++];
      final content = size != 0 ? data.skip(i).take(size).toList() : null;

      i += size;
      size = sizes[fieldIndex++];
      final etag =
          size != 0 ? utf8.decode(data.skip(i).take(size).toList()) : null;

      i += size;
      size = sizes[fieldIndex++];
      final headers = size != 0 ? data.skip(i).take(size).toList() : null;

      i += size;
      size = sizes[fieldIndex++];
      final lastModified =
          size != 0 ? utf8.decode(data.skip(i).take(size).toList()) : null;

      i += size;
      size = sizes[fieldIndex++];
      final maxStale =
          size != 0 ? utf8.decode(data.skip(i).take(size).toList()) : null;

      i += size;
      size = sizes[fieldIndex++];
      final url = utf8.decode(data.skip(i).take(size).toList());

      i += size;
      size = sizes[fieldIndex++];
      final cacheControl =
          size != 0 ? utf8.decode(data.skip(i).take(size).toList()) : null;

      i += size;
      size = sizes[fieldIndex++];
      final date =
          size != 0 ? utf8.decode(data.skip(i).take(size).toList()) : null;

      i += size;
      size = sizes[fieldIndex++];
      final expires =
          size != 0 ? utf8.decode(data.skip(i).take(size).toList()) : null;

      i += size;
      size = sizes[fieldIndex++];
      final responseDate = utf8.decode(data.skip(i).take(size).toList());

      i += size;
      size = sizes[fieldIndex++];
      final rawRequestDate =
          size != 0 ? utf8.decode(data.skip(i).take(size).toList()) : null;
      final requestDate = rawRequestDate != null
          ? DateTime.parse(rawRequestDate)
          : DateTime.parse(responseDate)
              .subtract(const Duration(milliseconds: 150));

      return CacheResponse(
        cacheControl: CacheControl.fromHeader(cacheControl?.split(', ')),
        content: content,
        date: date != null ? DateTime.tryParse(date) : null,
        eTag: etag,
        expires: expires != null ? DateTime.tryParse(expires) : null,
        headers: headers,
        key: path.basename(file.path),
        lastModified: lastModified,
        maxStale: maxStale != null
            ? DateTime.fromMillisecondsSinceEpoch(int.parse(maxStale),
                isUtc: true)
            : null,
        priority: _getPriority(file),
        requestDate: requestDate,
        responseDate: DateTime.parse(responseDate),
        url: url,
      );
    } catch (e) {
      // File is corrupted. Throw it away, we can't recover it.
      try {
        await file.delete();
      } catch (_) {}
    }

    return Future.value();
  }

  Future<void> _deleteFile(
    File? file, {
    bool staleOnly = false,
  }) async {
    if (staleOnly) {
      final resp = await _deserializeContent(file);
      if (resp == null || !resp.isStaled()) {
        return;
      }
    }

    try {
      await file?.delete();
    } catch (_) {}
  }

  CachePriority _getPriority(File file) {
    final priority = path.basename(file.parent.path);

    if (priority == CachePriority.low.toShortString()) {
      return CachePriority.low;
    } else if (priority == CachePriority.normal.toShortString()) {
      return CachePriority.normal;
    }

    return CachePriority.high;
  }

  Future<File?> _findFile(String key) async {
    for (final entry in _directories.entries) {
      final file = File(path.join(entry.value.path, key));
      if (await file.exists()) {
        return file;
      }
    }

    return null;
  }

  static Map<CachePriority, Directory> _genDirectories(String directory) {
    return Map.fromEntries(
      Iterable.generate(
        CachePriority.values.length,
        (i) {
          final priority = CachePriority.values[i];
          final subDir = Directory(
            path.join(directory, priority.toShortString()),
          );

          return MapEntry(priority, subDir);
        },
      ),
    );
  }
}
