import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;

import '../model/cache_priority.dart';
import '../model/cache_response.dart';
import 'cache_store.dart';

/// A store that save each request result in a dedicated file.
///
class FileCacheStore extends CacheStore {
  final Map<CachePriority, Directory> _directories;

  FileCacheStore(Directory directory)
      : assert(directory != null),
        _directories = _genDirectories(directory) {
    clean(stalledOnly: true);
  }

  File _findFile(String key) {
    for (final entry in _directories.entries) {
      final file = File(path.join(entry.value.path, key));
      if (file.existsSync()) {
        return file;
      }
    }

    return null;
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool stalledOnly = false,
  }) async {
    final futures = Iterable.generate(priorityOrBelow.index + 1, (i) async {
      final directory = _directories[CachePriority.values[i]];

      if (stalledOnly) {
        directory.listSync().forEach((file) async {
          await deleteFile(file, stalledOnly: stalledOnly);
        });
      }

      if (!stalledOnly || directory.listSync().isEmpty) {
        try {
          await directory.delete(recursive: true);
        } catch (_) {}
      }
    });

    return Future.wait(futures);
  }

  @override
  Future<void> delete(String key, {bool stalledOnly = false}) async {
    return deleteFile(_findFile(key), stalledOnly: stalledOnly);
  }

  @override
  Future<bool> exists(String key) {
    return Future.value(_findFile(key) != null);
  }

  @override
  Future<CacheResponse> get(String key) async {
    final file = _findFile(key);
    if (file == null) return Future.value();

    final resp = await _deserializeContent(file);

    // Purge entry if stalled
    final maxStale = resp.maxStale;
    if (maxStale != null) {
      if (DateTime.now().toUtc().isAfter(maxStale)) {
        await delete(key);
        return Future.value();
      }
    }

    return resp;
  }

  @override
  Future<void> set(CacheResponse response) async {
    await delete(response.key);

    final file = File(
      path.join(
        _directories[response.priority].path,
        response.key,
      ),
    );

    if (!file.parent.existsSync()) {
      await file.parent.create(recursive: true);
    }

    final bytes = _serializeContent(response);
    await file.writeAsBytes(bytes, flush: true);
  }

  List<int> _serializeContent(CacheResponse response) {
    final etag = utf8.encode(response.eTag ?? '');
    final lastModified = utf8.encode(response.lastModified ?? '');
    final maxStale = utf8.encode(response.getMaxStaleSeconds() ?? '');
    final url = utf8.encode(response.url);

    return [
      ...Int32List.fromList([
        response.content.length,
        etag.length,
        response.headers.length,
        lastModified.length,
        maxStale.length,
        url.length,
      ]).buffer.asInt8List(),
      ...response.content,
      ...etag,
      ...response.headers,
      ...lastModified,
      ...maxStale,
      ...url,
    ];
  }

  Future<CacheResponse> _deserializeContent(File file) async {
    final data = await file.readAsBytes();

    // Get field sizes
    // 6 fields. int is encoded with 4 bytes
    var i = 6 * 4;
    final sizes = Int8List.fromList(
      data.take(i).toList(),
    ).buffer.asInt32List();

    var fieldIndex = 0;

    var size = sizes[fieldIndex++];
    final content = data.skip(i).take(size).toList();

    i += size;
    size = sizes[fieldIndex++];
    final etag = utf8.decode(data.skip(i).take(size).toList());

    i += size;
    size = sizes[fieldIndex++];
    final headers = data.skip(i).take(size).toList();

    i += size;
    size = sizes[fieldIndex++];
    final lastModified = utf8.decode(data.skip(i).take(size).toList());

    i += size;
    size = sizes[fieldIndex++];
    final maxStale = utf8.decode(data.skip(i).take(size).toList());

    i += size;
    size = sizes[fieldIndex++];
    final url = utf8.decode(data.skip(i).take(size).toList());

    return CacheResponse(
      key: path.basename(file.path),
      content: content,
      eTag: etag,
      headers: headers,
      lastModified: lastModified,
      maxStale: maxStale.isNotEmpty
          ? DateTime.fromMillisecondsSinceEpoch(int.tryParse(maxStale) * 1000,
              isUtc: true)
          : null,
      priority: _getPriority(file),
      url: url,
    );
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

  Future<void> deleteFile(
    File file, {
    bool stalledOnly = false,
  }) async {
    if (file != null) {
      if (stalledOnly) {
        final resp = await _deserializeContent(file);
        if (resp.maxStale != null &&
            DateTime.now().toUtc().isBefore(resp.maxStale)) {
          return Future.value();
        }
      }

      try {
        await file.delete();
      } catch (_) {}
    }
  }
}

Map<CachePriority, Directory> _genDirectories(Directory directory) {
  return Map.fromEntries(
    Iterable.generate(
      CachePriority.values.length,
      (i) {
        final priority = CachePriority.values[i];
        final subDir = Directory(
          path.join(directory.path, priority.toShortString()),
        );

        return MapEntry(priority, subDir);
      },
    ),
  );
}
