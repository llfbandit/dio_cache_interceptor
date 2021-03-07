// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class DioCacheData extends DataClass implements Insertable<DioCacheData> {
  final String cacheKey;
  final DateTime? date;
  final String? cacheControl;
  final Uint8List? content;
  final String? eTag;
  final DateTime? expires;
  final Uint8List? headers;
  final String? lastModified;
  final DateTime? maxStale;
  final int priority;
  final DateTime responseDate;
  final String url;
  DioCacheData(
      {required this.cacheKey,
      this.date,
      this.cacheControl,
      this.content,
      this.eTag,
      this.expires,
      this.headers,
      this.lastModified,
      this.maxStale,
      required this.priority,
      required this.responseDate,
      required this.url});
  factory DioCacheData.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final uint8ListType = db.typeSystem.forDartType<Uint8List>();
    final intType = db.typeSystem.forDartType<int>();
    return DioCacheData(
      cacheKey: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}cacheKey'])!,
      date:
          dateTimeType.mapFromDatabaseResponse(data['${effectivePrefix}date']),
      cacheControl: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}cacheControl']),
      content: uint8ListType
          .mapFromDatabaseResponse(data['${effectivePrefix}content']),
      eTag: stringType.mapFromDatabaseResponse(data['${effectivePrefix}eTag']),
      expires: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}expires']),
      headers: uint8ListType
          .mapFromDatabaseResponse(data['${effectivePrefix}headers']),
      lastModified: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}lastModified']),
      maxStale: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}maxStale']),
      priority:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}priority'])!,
      responseDate: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}responseDate'])!,
      url: stringType.mapFromDatabaseResponse(data['${effectivePrefix}url'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cacheKey'] = Variable<String>(cacheKey);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime?>(date);
    }
    if (!nullToAbsent || cacheControl != null) {
      map['cacheControl'] = Variable<String?>(cacheControl);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<Uint8List?>(content);
    }
    if (!nullToAbsent || eTag != null) {
      map['eTag'] = Variable<String?>(eTag);
    }
    if (!nullToAbsent || expires != null) {
      map['expires'] = Variable<DateTime?>(expires);
    }
    if (!nullToAbsent || headers != null) {
      map['headers'] = Variable<Uint8List?>(headers);
    }
    if (!nullToAbsent || lastModified != null) {
      map['lastModified'] = Variable<String?>(lastModified);
    }
    if (!nullToAbsent || maxStale != null) {
      map['maxStale'] = Variable<DateTime?>(maxStale);
    }
    map['priority'] = Variable<int>(priority);
    map['responseDate'] = Variable<DateTime>(responseDate);
    map['url'] = Variable<String>(url);
    return map;
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'date': serializer.toJson<DateTime?>(date),
      'cacheControl': serializer.toJson<String?>(cacheControl),
      'content': serializer.toJson<Uint8List?>(content),
      'eTag': serializer.toJson<String?>(eTag),
      'expires': serializer.toJson<DateTime?>(expires),
      'headers': serializer.toJson<Uint8List?>(headers),
      'lastModified': serializer.toJson<String?>(lastModified),
      'maxStale': serializer.toJson<DateTime?>(maxStale),
      'priority': serializer.toJson<int>(priority),
      'responseDate': serializer.toJson<DateTime>(responseDate),
      'url': serializer.toJson<String>(url),
    };
  }
}

class DioCache extends Table with TableInfo<DioCache, DioCacheData> {
  final GeneratedDatabase _db;
  final String? _alias;
  DioCache(this._db, [this._alias]);
  late final GeneratedTextColumn cacheKey = _constructCacheKey();
  GeneratedTextColumn _constructCacheKey() {
    return GeneratedTextColumn('cacheKey', $tableName, false,
        $customConstraints: 'NOT NULL PRIMARY KEY');
  }

  late final GeneratedDateTimeColumn date = _constructDate();
  GeneratedDateTimeColumn _constructDate() {
    return GeneratedDateTimeColumn('date', $tableName, true,
        $customConstraints: '');
  }

  late final GeneratedTextColumn cacheControl = _constructCacheControl();
  GeneratedTextColumn _constructCacheControl() {
    return GeneratedTextColumn('cacheControl', $tableName, true,
        $customConstraints: '');
  }

  late final GeneratedBlobColumn content = _constructContent();
  GeneratedBlobColumn _constructContent() {
    return GeneratedBlobColumn('content', $tableName, true,
        $customConstraints: '');
  }

  late final GeneratedTextColumn eTag = _constructETag();
  GeneratedTextColumn _constructETag() {
    return GeneratedTextColumn('eTag', $tableName, true,
        $customConstraints: '');
  }

  late final GeneratedDateTimeColumn expires = _constructExpires();
  GeneratedDateTimeColumn _constructExpires() {
    return GeneratedDateTimeColumn('expires', $tableName, true,
        $customConstraints: '');
  }

  late final GeneratedBlobColumn headers = _constructHeaders();
  GeneratedBlobColumn _constructHeaders() {
    return GeneratedBlobColumn('headers', $tableName, true,
        $customConstraints: '');
  }

  late final GeneratedTextColumn lastModified = _constructLastModified();
  GeneratedTextColumn _constructLastModified() {
    return GeneratedTextColumn('lastModified', $tableName, true,
        $customConstraints: '');
  }

  late final GeneratedDateTimeColumn maxStale = _constructMaxStale();
  GeneratedDateTimeColumn _constructMaxStale() {
    return GeneratedDateTimeColumn('maxStale', $tableName, true,
        $customConstraints: '');
  }

  late final GeneratedIntColumn priority = _constructPriority();
  GeneratedIntColumn _constructPriority() {
    return GeneratedIntColumn('priority', $tableName, false,
        $customConstraints: 'NOT NULL');
  }

  late final GeneratedDateTimeColumn responseDate = _constructResponseDate();
  GeneratedDateTimeColumn _constructResponseDate() {
    return GeneratedDateTimeColumn('responseDate', $tableName, false,
        $customConstraints: 'NOT NULL');
  }

  late final GeneratedTextColumn url = _constructUrl();
  GeneratedTextColumn _constructUrl() {
    return GeneratedTextColumn('url', $tableName, false,
        $customConstraints: 'NOT NULL');
  }

  @override
  List<GeneratedColumn> get $columns => [
        cacheKey,
        date,
        cacheControl,
        content,
        eTag,
        expires,
        headers,
        lastModified,
        maxStale,
        priority,
        responseDate,
        url
      ];
  @override
  DioCache get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'DioCache';
  @override
  final String actualTableName = 'DioCache';
  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  DioCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return DioCacheData.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  DioCache createAlias(String alias) {
    return DioCache(_db, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

abstract class _$DioCacheDatabase extends GeneratedDatabase {
  _$DioCacheDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final DioCache dioCache = DioCache(this);
  late final DioCacheDao dioCacheDao = DioCacheDao(this as DioCacheDatabase);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [dioCache];
}

// **************************************************************************
// DaoGenerator
// **************************************************************************

mixin _$DioCacheDaoMixin on DatabaseAccessor<DioCacheDatabase> {
  DioCache get dioCache => attachedDatabase.dioCache;
}
