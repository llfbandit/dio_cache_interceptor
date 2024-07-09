import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_realm_store/src/annotations/named_realm_annotations.dart';
import 'package:realm_dart/realm.dart';

part 'dio_cache_realm_models.realm.dart';

@realm
class $CacheResponseRealm {
  @PrimaryKey()
  late String key;

  late $CacheControlRealm? cacheControl;
  late List<int> content;
  late DateTime? date;
  late String? eTag;
  late DateTime? expires;
  late List<int> headers;
  late String? lastModified;
  late DateTime? maxStale;
  late DateTime? requestDate;
  late DateTime responseDate;
  late String url;

  @MapTo('cachePriority')
  late int _priority;
  CachePriority get cachePriority {
    switch (_priority) {
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

  set cachePriority(CachePriority value) => _priority = value.index;

  CacheResponse toObject() {
    // Realm stores dates in UTC so we need to convert them back to local.
    return CacheResponse(
      cacheControl: cacheControl?.toObject() ?? CacheControl(),
      content: content,
      date: date?.toLocal(),
      eTag: eTag,
      expires: expires?.toLocal(),
      headers: headers,
      key: key,
      lastModified: lastModified,
      maxStale: maxStale?.toLocal(),
      priority: cachePriority,
      requestDate: (requestDate ??
              responseDate.subtract(
                const Duration(milliseconds: 150),
              ))
          .toLocal(),
      responseDate: responseDate.toLocal(),
      url: url,
    );
  }

  static CacheResponseRealm fromObject(CacheResponse response) {
    // Realm requires date to be in UTC.
    final result = CacheResponseRealm(
      key: response.key,
      content: response.content ?? [],
      date: response.date?.toUtc(),
      eTag: response.eTag,
      expires: response.expires?.toUtc(),
      headers: response.headers ?? [],
      lastModified: response.lastModified,
      maxStale: response.maxStale?.toUtc(),
      responseDate: response.responseDate.toUtc(),
      url: response.url,
      requestDate: response.requestDate.toUtc(),
      priority: response.priority.index,
      cacheControl: CacheControlRealm(
        maxAge: response.cacheControl.maxAge,
        privacy: response.cacheControl.privacy,
        noCache: response.cacheControl.noCache,
        noStore: response.cacheControl.noStore,
        other: response.cacheControl.other,
      ),
    );

    return result;
  }
}

@realmEmbedded
class $CacheControlRealm {
  late int? maxAge;
  late String? privacy;
  late int? maxStale;
  late int? minFresh;
  late bool? mustRevalidate;
  late bool? noCache;
  late bool? noStore;
  late List<String> other;

  CacheControl toObject() {
    return CacheControl(
      maxAge: maxAge ?? -1,
      privacy: privacy,
      noCache: noCache ?? false,
      noStore: noStore ?? false,
      other: other,
      maxStale: maxStale ?? -1,
      minFresh: minFresh ?? -1,
      mustRevalidate: mustRevalidate ?? false,
    );
  }
}
