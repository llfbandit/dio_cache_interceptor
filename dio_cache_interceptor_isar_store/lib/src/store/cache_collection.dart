import 'package:isar/isar.dart';

part 'cache_collection.g.dart';

@collection
class Cache {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late final String cacheKey;
  DateTime? date;
  String? cacheControl;
  List<int>? content;
  String? eTag;
  DateTime? expires;
  List<int>? headers;
  String? lastModified;
  DateTime? maxStale;
  late int priority;
  DateTime? requestDate;
  late final DateTime responseDate;
  late final String url;
}
