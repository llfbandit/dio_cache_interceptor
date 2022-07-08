import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:hive/hive.dart';

/// A store saving responses using hive.
///
class HiveCacheStore extends CacheStore {
  // Cache box name
  final String hiveBoxName;
  // Optional cipher to use directly with Hive
  final HiveCipher? encryptionCipher;

  LazyBox<CacheResponse>? _box;

  /// Initialize cache store by giving Hive a home directory.
  /// [directory] can be null only on web platform or if you already use Hive
  /// in your app.
  HiveCacheStore(
    String? directory, {
    this.hiveBoxName = 'dio_cache',
    this.encryptionCipher,
  }) {
    if (directory != null) {
      Hive.init(directory);
    }

    if (!Hive.isAdapterRegistered(_CacheResponseAdapter._typeId)) {
      Hive.registerAdapter(_CacheResponseAdapter());
    }
    if (!Hive.isAdapterRegistered(_CacheControlAdapter._typeId)) {
      Hive.registerAdapter(_CacheControlAdapter());
    }
    if (!Hive.isAdapterRegistered(_CachePriorityAdapter._typeId)) {
      Hive.registerAdapter(_CachePriorityAdapter());
    }

    clean(staleOnly: true);
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    final box = await _openBox();

    final keys = <String>[];

    for (var i = 0; i < box.keys.length; i++) {
      final resp = await box.getAt(i);

      if (resp != null) {
        var shouldRemove = resp.priority.index <= priorityOrBelow.index;
        shouldRemove &= (staleOnly && resp.isStaled()) || !staleOnly;

        if (shouldRemove) {
          keys.add(resp.key);
        }
      }
    }

    return box.deleteAll(keys);
  }

  @override
  Future<void> close() {
    final checkedBox = _box;
    if (checkedBox != null && checkedBox.isOpen) {
      _box = null;
      return checkedBox.close();
    }

    return Future.value();
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    final box = await _openBox();
    final resp = await box.get(key);
    if (resp == null) return Future.value();

    if (staleOnly && !resp.isStaled()) {
      return Future.value();
    }

    await box.delete(key);
  }

  @override
  Future<void> deleteFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final responses = await getFromPath(pathPattern, queryParams: queryParams);

    final box = await _openBox();

    for (final response in responses) {
      await box.delete(response.key);
    }
  }

  @override
  Future<bool> exists(String key) async {
    final box = await _openBox();
    return box.containsKey(key);
  }

  @override
  Future<CacheResponse?> get(String key) async {
    final box = await _openBox();
    return box.get(key);
  }

  @override
  Future<List<CacheResponse>> getFromPath(
    RegExp pathPattern, {
    Map<String, String?>? queryParams,
  }) async {
    final responses = <CacheResponse>[];

    final box = await _openBox();

    for (var i = 0; i < box.keys.length; i++) {
      final resp = await box.getAt(i);

      if (resp != null) {
        if (pathExists(resp.url, pathPattern, queryParams: queryParams)) {
          responses.add(resp);
        }
      }
    }

    return responses;
  }

  @override
  Future<void> set(CacheResponse response) async {
    final box = await _openBox();
    return box.put(response.key, response);
  }

  Future<LazyBox<CacheResponse>> _openBox() async {
    _box ??= await Hive.openLazyBox<CacheResponse>(
      hiveBoxName,
      encryptionCipher: encryptionCipher,
    );

    return Future.value(_box);
  }
}

class _CacheResponseAdapter extends TypeAdapter<CacheResponse> {
  static const int _typeId = 93;

  @override
  final int typeId = _typeId;

  @override
  CacheResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheResponse(
      cacheControl: fields[0] as CacheControl? ?? CacheControl(),
      content: (fields[1] as List?)?.cast<int>(),
      date: fields[2] as DateTime?,
      eTag: fields[3] as String?,
      expires: fields[4] as DateTime?,
      headers: (fields[5] as List?)?.cast<int>(),
      key: fields[6] as String,
      lastModified: fields[7] as String?,
      maxStale: fields[8] as DateTime?,
      priority: fields[9] as CachePriority,
      responseDate: fields[10] as DateTime,
      url: fields[11] as String,
      requestDate: fields[12] != null
          ? fields[12] as DateTime
          : (fields[10] as DateTime)
              .subtract(const Duration(milliseconds: 150)),
    );
  }

  @override
  void write(BinaryWriter writer, CacheResponse obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.cacheControl)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.eTag)
      ..writeByte(4)
      ..write(obj.expires)
      ..writeByte(5)
      ..write(obj.headers)
      ..writeByte(6)
      ..write(obj.key)
      ..writeByte(7)
      ..write(obj.lastModified)
      ..writeByte(8)
      ..write(obj.maxStale)
      ..writeByte(9)
      ..write(obj.priority)
      ..writeByte(10)
      ..write(obj.responseDate)
      ..writeByte(11)
      ..write(obj.url)
      ..writeByte(12)
      ..write(obj.requestDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CacheResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class _CacheControlAdapter extends TypeAdapter<CacheControl> {
  static const int _typeId = 94;

  @override
  final int typeId = _typeId;

  @override
  CacheControl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheControl(
      maxAge: fields[0] as int? ?? -1,
      privacy: fields[1] as String?,
      noCache: fields[2] as bool? ?? false,
      noStore: fields[3] as bool? ?? false,
      other: (fields[4] as List).cast<String>(),
      maxStale: fields[5] as int? ?? -1,
      minFresh: fields[6] as int? ?? -1,
      mustRevalidate: fields[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, CacheControl obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.maxAge)
      ..writeByte(1)
      ..write(obj.privacy)
      ..writeByte(2)
      ..write(obj.noCache)
      ..writeByte(3)
      ..write(obj.noStore)
      ..writeByte(4)
      ..write(obj.other)
      ..writeByte(5)
      ..write(obj.maxStale)
      ..writeByte(6)
      ..write(obj.minFresh)
      ..writeByte(7)
      ..write(obj.mustRevalidate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CacheControlAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class _CachePriorityAdapter extends TypeAdapter<CachePriority> {
  static const int _typeId = 95;

  @override
  final int typeId = _typeId;

  @override
  CachePriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CachePriority.low;
      case 2:
        return CachePriority.high;
      case 1:
      default:
        return CachePriority.normal;
    }
  }

  @override
  void write(BinaryWriter writer, CachePriority obj) {
    switch (obj) {
      case CachePriority.low:
        writer.writeByte(0);
        break;
      case CachePriority.normal:
        writer.writeByte(1);
        break;
      case CachePriority.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CachePriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
