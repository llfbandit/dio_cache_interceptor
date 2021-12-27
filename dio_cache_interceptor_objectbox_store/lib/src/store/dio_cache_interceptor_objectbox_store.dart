import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_objectbox_store/objectbox.g.dart';

/// A store saving responses using ObjectBox.
///
class ObjectBoxCacheStore implements CacheStore {
  /// ObjectBox store file path
  final String storePath;

  /// ObjectBox store
  Store? _store;

  /// ObjectBox box instance for [CacheResponseBox]
  Box<CacheResponseBox>? _box;

  ObjectBoxCacheStore({required this.storePath}) {
    clean(staleOnly: true);
  }

  Box<CacheResponseBox> _openBox() {
    if (_box == null) {
      _store = Store(getObjectBoxModel(), directory: '$storePath/cache-api');
      _box = _store!.box<CacheResponseBox>();
    }
    return _box!;
  }

  @override
  Future<void> clean({
    CachePriority priorityOrBelow = CachePriority.high,
    bool staleOnly = false,
  }) async {
    final box = _openBox();

    final results = box
        .query(CacheResponseBox_.priority.lessOrEqual(priorityOrBelow.index))
        .build()
        .find();

    for (final result in results) {
      if ((staleOnly && result.toObject().isStaled()) || !staleOnly) {
        box.remove(result.id!);
      }
    }
  }

  @override
  Future<void> close() async {
    return _store?.close();
  }

  @override
  Future<void> delete(String key, {bool staleOnly = false}) async {
    final box = _openBox();
    final resp =
        box.query(CacheResponseBox_.key.equals(key)).build().findFirst();
    if (resp == null) return Future.value();

    if (staleOnly && !resp.toObject().isStaled()) {
      return Future.value();
    }

    box.remove(resp.id!);
  }

  @override
  Future<bool> exists(String key) async {
    final box = _openBox();
    return box.query(CacheResponseBox_.key.equals(key)).build().findFirst() !=
        null;
  }

  @override
  Future<CacheResponse?> get(String key) async {
    final box = _openBox();
    final resp =
        box.query(CacheResponseBox_.key.equals(key)).build().findFirst();
    if (resp == null) return null;

    if (resp.toObject().isStaled()) {
      await delete(key);
      return null;
    }
    return resp.toObject();
  }

  @override
  Future<void> set(CacheResponse response) async {
    final box = _openBox();
    await delete(response.key);
    box.put(CacheResponseBox.fromObject(response));
  }
}

@Entity()
class CacheResponseBox {
  CacheResponseBox({
    required this.key,
    this.content,
    this.date,
    this.eTag,
    this.expires,
    this.headers,
    this.lastModified,
    this.maxStale,
    required this.priority,
    required this.responseDate,
    required this.url,
  });

  @Id()
  int? id;
  String key;

  @Property(type: PropertyType.byteVector)
  List<int>? content;

  @Property(type: PropertyType.date)
  DateTime? date;

  String? eTag;

  @Property(type: PropertyType.date)
  DateTime? expires;

  @Property(type: PropertyType.byteVector)
  List<int>? headers;

  String? lastModified;

  @Property(type: PropertyType.date)
  DateTime? maxStale;

  @Property(type: PropertyType.date)
  DateTime responseDate;

  String url;

  int priority;

  final cacheControl = ToOne<CacheControlBox>();

  CachePriority get cachePriority {
    switch (priority) {
      case 0:
        return CachePriority.low;
      case 1:
        return CachePriority.normal;
      case 2:
        return CachePriority.high;
      default:
        return CachePriority.low;
    }
  }

  CacheResponse toObject() {
    return CacheResponse(
      cacheControl: cacheControl.target?.toObject(),
      content: content,
      date: date,
      eTag: eTag,
      expires: expires,
      headers: headers,
      key: key,
      lastModified: lastModified,
      maxStale: maxStale,
      priority: cachePriority,
      responseDate: responseDate,
      url: url,
    );
  }

  static CacheResponseBox fromObject(CacheResponse response) {
    final result = CacheResponseBox(
      key: response.key,
      content: response.content,
      date: response.date,
      eTag: response.eTag,
      expires: response.expires,
      headers: response.headers,
      lastModified: response.lastModified,
      maxStale: response.maxStale,
      responseDate: response.responseDate,
      url: response.url,
      priority: response.priority.index,
    );

    if (response.cacheControl != null) {
      result.cacheControl.target = CacheControlBox(
        maxAge: response.cacheControl!.maxAge,
        privacy: response.cacheControl!.privacy,
        noCache: response.cacheControl!.noCache,
        noStore: response.cacheControl!.noStore,
        other: response.cacheControl!.other,
      );
    }

    return result;
  }
}

@Entity()
class CacheControlBox {
  CacheControlBox({
    this.id,
    this.maxAge,
    this.privacy,
    this.noCache,
    this.noStore,
    this.other,
  });

  @Id()
  int? id;
  int? maxAge;
  String? privacy;
  bool? noCache;
  bool? noStore;
  List<String>? other;

  CacheControl toObject() {
    return CacheControl(
      maxAge: maxAge,
      privacy: privacy,
      noCache: noCache,
      noStore: noStore,
      other: other ?? [],
    );
  }
}
