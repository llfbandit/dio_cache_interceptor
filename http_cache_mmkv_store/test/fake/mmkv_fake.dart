import 'dart:typed_data';

import 'package:mmkv/mmkv.dart';

class MMKVFake implements MMKV {
  var _data = <String, Object?>{};

  @override
  int get actualSize => _data.length;

  @override
  List<String> get allKeys => _data.keys.toList();

  @override
  List<String> get allNonExpiredKeys => _data.keys.toList();

  @override
  void checkContentChangedByOuterProcess() {
    // TODO: implement checkContentChangedByOuterProcess
  }

  @override
  void checkReSetCryptKey(String cryptKey) {
    // TODO: implement checkReSetCryptKey
  }

  @override
  void clearAll({bool keepSpace = false}) {
    _data = {};
  }

  @override
  void clearMemoryCache() {
    _data = {};
  }

  @override
  void close() {
    // TODO: implement close
  }

  @override
  bool containsKey(String key) {
    return _data[key] != null;
  }

  @override
  int get count => _data.length;

  @override
  int get countNonExpiredKeys => _data.length;

  @override
  String? get cryptKey => null;

  @override
  bool decodeBool(String key, {bool defaultValue = false}) {
    return _data[key] as bool;
  }

  @override
  MMBuffer? decodeBytes(String key) {
    final bytes = _data[key] as Uint8List?;
    if (bytes != null) return MMBuffer.fromList(bytes);
    return null;
  }

  @override
  double decodeDouble(String key, {double defaultValue = 0}) {
    return _data[key] as double;
  }

  @override
  int decodeInt(String key, {int defaultValue = 0}) {
    return _data[key] as int;
  }

  @override
  int decodeInt32(String key, {int defaultValue = 0}) {
    return _data[key] as int;
  }

  @override
  String? decodeString(String key) {
    return _data[key] as String;
  }

  @override
  bool disableAutoKeyExpire() {
    return true;
  }

  @override
  bool disableCompareBeforeSet() {
    return true;
  }

  @override
  bool enableAutoKeyExpire(int expiredInSeconds) {
    return true;
  }

  @override
  bool enableCompareBeforeSet() {
    return true;
  }

  @override
  bool encodeBool(String key, bool value, [int? expireDurationInSecond]) {
    _data[key] = value;
    return true;
  }

  @override
  bool encodeBytes(String key, MMBuffer? value, [int? expireDurationInSecond]) {
    _data[key] = Uint8List.fromList(value?.asList() ?? []);
    return true;
  }

  @override
  bool encodeDouble(String key, double value, [int? expireDurationInSecond]) {
    _data[key] = value;
    return true;
  }

  @override
  bool encodeInt(String key, int value, [int? expireDurationInSecond]) {
    _data[key] = value;
    return true;
  }

  @override
  bool encodeInt32(String key, int value, [int? expireDurationInSecond]) {
    _data[key] = value;
    return true;
  }

  @override
  bool encodeString(String key, String? value, [int? expireDurationInSecond]) {
    _data[key] = value;
    return true;
  }

  @override
  bool get isMultiProcess => false;

  @override
  bool get isReadOnly => false;

  @override
  String get mmapID => '';

  @override
  bool reKey(String? cryptKey) {
    return true;
  }

  @override
  void removeValue(String key) {
    _data.remove(key);
  }

  @override
  void removeValues(List<String> keys) {
    keys.forEach(removeValue);
  }

  @override
  void sync(bool sync) {
    // TODO: implement sync
  }

  @override
  int get totalSize => 0;

  @override
  void trim() {
    // TODO: implement trim
  }

  @override
  int valueSize(String key, bool actualSize) {
    return 0;
  }

  @override
  int writeValueToNativeBuffer(String key, MMBuffer buffer) {
    return 0;
  }

  @override
  int importFrom(MMKV src) {
    return 0;
  }
}
