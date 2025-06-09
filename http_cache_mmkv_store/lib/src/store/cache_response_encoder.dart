import 'dart:typed_data';

import 'package:http_cache_core/http_cache_core.dart';
import 'package:messagepack/messagepack.dart';

extension CachePriorityEncoder on CachePriority {
  Uint8List toBytes() {
    final packer = Packer()..packInt(index);
    return packer.takeBytes();
  }

  static CachePriority cachePriorityFromBytes(Uint8List bytes) {
    final index = Unpacker(bytes).unpackInt();
    switch (index) {
      case 0:
        return CachePriority.low;
      case 2:
        return CachePriority.high;
      case 1:
      default:
        return CachePriority.normal;
    }
  }
}

extension CacheResponseEncoder on CacheResponse {
  Uint8List toBytes() {
    final packer = Packer()
      ..packListLength(14)
      ..packBinary(cacheControl.toBytes())
      ..packBinary(content)
      ..packString(date?.toIso8601String())
      ..packString(eTag)
      ..packString(expires?.toIso8601String())
      ..packBinary(headers)
      ..packString(key)
      ..packString(lastModified)
      ..packString(maxStale?.toIso8601String())
      ..packBinary(priority.toBytes())
      ..packString(responseDate.toIso8601String())
      ..packString(url)
      ..packString(requestDate.toIso8601String())
      ..packInt(statusCode);
    return packer.takeBytes();
  }

  static CacheResponse cacheResponseFromBytes(Uint8List bytes) {
    final fields = Unpacker(bytes).unpackList();
    return CacheResponse(
      cacheControl: CacheControlEncoder.cacheControlFromBytes(
          fields[0].castToUnit8List()),
      content: (fields[1] as List?)?.cast<int>(),
      date: fields[2] != null ? DateTime.parse(fields[2] as String) : null,
      eTag: fields[3] as String?,
      expires: fields[4] != null ? DateTime.parse(fields[4] as String) : null,
      headers: (fields[5] as List?)?.cast<int>(),
      key: fields[6] as String,
      lastModified: fields[7] as String?,
      maxStale: fields[8] != null ? DateTime.parse(fields[8] as String) : null,
      priority: CachePriorityEncoder.cachePriorityFromBytes(
          fields[9].castToUnit8List()),
      responseDate: DateTime.parse(fields[10] as String),
      url: fields[11] as String,
      requestDate: fields[12] != null
          ? DateTime.parse(fields[12] as String)
          : DateTime.parse(fields[10] as String)
              .subtract(const Duration(milliseconds: 150)),
      statusCode: fields[13] as int,
    );
  }
}

extension ObjectX on Object? {
  Uint8List castToUnit8List() {
    return Uint8List.fromList((this as List?)?.cast<int>() ?? []);
  }
}

extension CacheControlEncoder on CacheControl {
  Uint8List toBytes() {
    final packer = Packer()
      ..packListLength(8)
      ..packInt(maxAge)
      ..packString(privacy)
      ..packBool(noCache)
      ..packBool(noStore)
      ..packListString(other)
      ..packInt(maxStale)
      ..packInt(minFresh)
      ..packBool(mustRevalidate);
    return packer.takeBytes();
  }

  static CacheControl cacheControlFromBytes(Uint8List bytes) {
    final fields = Unpacker(bytes).unpackList();
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
}

extension PackerUtils on Packer {
  void packListString(List<String> strings) {
    packListLength(strings.length);
    strings.forEach(packString);
  }
}
