// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class _DioCacheData extends DataClass implements Insertable<_DioCacheData> {
  final String key;
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
  _DioCacheData(
      {required this.key,
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
  factory _DioCacheData.fromData(
      Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final uint8ListType = db.typeSystem.forDartType<Uint8List>();
    final intType = db.typeSystem.forDartType<int>();
    return _DioCacheData(
      key: stringType.mapFromDatabaseResponse(data['${effectivePrefix}key'])!,
      date:
          dateTimeType.mapFromDatabaseResponse(data['${effectivePrefix}date']),
      cacheControl: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}cache_control']),
      content: uint8ListType
          .mapFromDatabaseResponse(data['${effectivePrefix}content']),
      eTag: stringType.mapFromDatabaseResponse(data['${effectivePrefix}e_tag']),
      expires: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}expires']),
      headers: uint8ListType
          .mapFromDatabaseResponse(data['${effectivePrefix}headers']),
      lastModified: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}last_modified']),
      maxStale: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}max_stale']),
      priority:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}priority'])!,
      responseDate: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}response_date'])!,
      url: stringType.mapFromDatabaseResponse(data['${effectivePrefix}url'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime?>(date);
    }
    if (!nullToAbsent || cacheControl != null) {
      map['cache_control'] = Variable<String?>(cacheControl);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<Uint8List?>(content);
    }
    if (!nullToAbsent || eTag != null) {
      map['e_tag'] = Variable<String?>(eTag);
    }
    if (!nullToAbsent || expires != null) {
      map['expires'] = Variable<DateTime?>(expires);
    }
    if (!nullToAbsent || headers != null) {
      map['headers'] = Variable<Uint8List?>(headers);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<String?>(lastModified);
    }
    if (!nullToAbsent || maxStale != null) {
      map['max_stale'] = Variable<DateTime?>(maxStale);
    }
    map['priority'] = Variable<int>(priority);
    map['response_date'] = Variable<DateTime>(responseDate);
    map['url'] = Variable<String>(url);
    return map;
  }

  factory _DioCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return _DioCacheData(
      key: serializer.fromJson<String>(json['key']),
      date: serializer.fromJson<DateTime?>(json['date']),
      cacheControl: serializer.fromJson<String?>(json['cacheControl']),
      content: serializer.fromJson<Uint8List?>(json['content']),
      eTag: serializer.fromJson<String?>(json['eTag']),
      expires: serializer.fromJson<DateTime?>(json['expires']),
      headers: serializer.fromJson<Uint8List?>(json['headers']),
      lastModified: serializer.fromJson<String?>(json['lastModified']),
      maxStale: serializer.fromJson<DateTime?>(json['maxStale']),
      priority: serializer.fromJson<int>(json['priority']),
      responseDate: serializer.fromJson<DateTime>(json['responseDate']),
      url: serializer.fromJson<String>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
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

  _DioCacheData copyWith(
          {String? key,
          DateTime? date,
          String? cacheControl,
          Uint8List? content,
          String? eTag,
          DateTime? expires,
          Uint8List? headers,
          String? lastModified,
          DateTime? maxStale,
          int? priority,
          DateTime? responseDate,
          String? url}) =>
      _DioCacheData(
        key: key ?? this.key,
        date: date ?? this.date,
        cacheControl: cacheControl ?? this.cacheControl,
        content: content ?? this.content,
        eTag: eTag ?? this.eTag,
        expires: expires ?? this.expires,
        headers: headers ?? this.headers,
        lastModified: lastModified ?? this.lastModified,
        maxStale: maxStale ?? this.maxStale,
        priority: priority ?? this.priority,
        responseDate: responseDate ?? this.responseDate,
        url: url ?? this.url,
      );
  @override
  String toString() {
    return (StringBuffer('_DioCacheData(')
          ..write('key: $key, ')
          ..write('date: $date, ')
          ..write('cacheControl: $cacheControl, ')
          ..write('content: $content, ')
          ..write('eTag: $eTag, ')
          ..write('expires: $expires, ')
          ..write('headers: $headers, ')
          ..write('lastModified: $lastModified, ')
          ..write('maxStale: $maxStale, ')
          ..write('priority: $priority, ')
          ..write('responseDate: $responseDate, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      key.hashCode,
      $mrjc(
          date.hashCode,
          $mrjc(
              cacheControl.hashCode,
              $mrjc(
                  content.hashCode,
                  $mrjc(
                      eTag.hashCode,
                      $mrjc(
                          expires.hashCode,
                          $mrjc(
                              headers.hashCode,
                              $mrjc(
                                  lastModified.hashCode,
                                  $mrjc(
                                      maxStale.hashCode,
                                      $mrjc(
                                          priority.hashCode,
                                          $mrjc(responseDate.hashCode,
                                              url.hashCode))))))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is _DioCacheData &&
          other.key == this.key &&
          other.date == this.date &&
          other.cacheControl == this.cacheControl &&
          other.content == this.content &&
          other.eTag == this.eTag &&
          other.expires == this.expires &&
          other.headers == this.headers &&
          other.lastModified == this.lastModified &&
          other.maxStale == this.maxStale &&
          other.priority == this.priority &&
          other.responseDate == this.responseDate &&
          other.url == this.url);
}

class _DioCacheCompanion extends UpdateCompanion<_DioCacheData> {
  final Value<String> key;
  final Value<DateTime?> date;
  final Value<String?> cacheControl;
  final Value<Uint8List?> content;
  final Value<String?> eTag;
  final Value<DateTime?> expires;
  final Value<Uint8List?> headers;
  final Value<String?> lastModified;
  final Value<DateTime?> maxStale;
  final Value<int> priority;
  final Value<DateTime> responseDate;
  final Value<String> url;
  const _DioCacheCompanion({
    this.key = const Value.absent(),
    this.date = const Value.absent(),
    this.cacheControl = const Value.absent(),
    this.content = const Value.absent(),
    this.eTag = const Value.absent(),
    this.expires = const Value.absent(),
    this.headers = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.maxStale = const Value.absent(),
    this.priority = const Value.absent(),
    this.responseDate = const Value.absent(),
    this.url = const Value.absent(),
  });
  _DioCacheCompanion.insert({
    required String key,
    this.date = const Value.absent(),
    this.cacheControl = const Value.absent(),
    this.content = const Value.absent(),
    this.eTag = const Value.absent(),
    this.expires = const Value.absent(),
    this.headers = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.maxStale = const Value.absent(),
    required int priority,
    required DateTime responseDate,
    required String url,
  })   : key = Value(key),
        priority = Value(priority),
        responseDate = Value(responseDate),
        url = Value(url);
  static Insertable<_DioCacheData> custom({
    Expression<String>? key,
    Expression<DateTime?>? date,
    Expression<String?>? cacheControl,
    Expression<Uint8List?>? content,
    Expression<String?>? eTag,
    Expression<DateTime?>? expires,
    Expression<Uint8List?>? headers,
    Expression<String?>? lastModified,
    Expression<DateTime?>? maxStale,
    Expression<int>? priority,
    Expression<DateTime>? responseDate,
    Expression<String>? url,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (date != null) 'date': date,
      if (cacheControl != null) 'cache_control': cacheControl,
      if (content != null) 'content': content,
      if (eTag != null) 'e_tag': eTag,
      if (expires != null) 'expires': expires,
      if (headers != null) 'headers': headers,
      if (lastModified != null) 'last_modified': lastModified,
      if (maxStale != null) 'max_stale': maxStale,
      if (priority != null) 'priority': priority,
      if (responseDate != null) 'response_date': responseDate,
      if (url != null) 'url': url,
    });
  }

  _DioCacheCompanion copyWith(
      {Value<String>? key,
      Value<DateTime?>? date,
      Value<String?>? cacheControl,
      Value<Uint8List?>? content,
      Value<String?>? eTag,
      Value<DateTime?>? expires,
      Value<Uint8List?>? headers,
      Value<String?>? lastModified,
      Value<DateTime?>? maxStale,
      Value<int>? priority,
      Value<DateTime>? responseDate,
      Value<String>? url}) {
    return _DioCacheCompanion(
      key: key ?? this.key,
      date: date ?? this.date,
      cacheControl: cacheControl ?? this.cacheControl,
      content: content ?? this.content,
      eTag: eTag ?? this.eTag,
      expires: expires ?? this.expires,
      headers: headers ?? this.headers,
      lastModified: lastModified ?? this.lastModified,
      maxStale: maxStale ?? this.maxStale,
      priority: priority ?? this.priority,
      responseDate: responseDate ?? this.responseDate,
      url: url ?? this.url,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime?>(date.value);
    }
    if (cacheControl.present) {
      map['cache_control'] = Variable<String?>(cacheControl.value);
    }
    if (content.present) {
      map['content'] = Variable<Uint8List?>(content.value);
    }
    if (eTag.present) {
      map['e_tag'] = Variable<String?>(eTag.value);
    }
    if (expires.present) {
      map['expires'] = Variable<DateTime?>(expires.value);
    }
    if (headers.present) {
      map['headers'] = Variable<Uint8List?>(headers.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<String?>(lastModified.value);
    }
    if (maxStale.present) {
      map['max_stale'] = Variable<DateTime?>(maxStale.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (responseDate.present) {
      map['response_date'] = Variable<DateTime>(responseDate.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('_DioCacheCompanion(')
          ..write('key: $key, ')
          ..write('date: $date, ')
          ..write('cacheControl: $cacheControl, ')
          ..write('content: $content, ')
          ..write('eTag: $eTag, ')
          ..write('expires: $expires, ')
          ..write('headers: $headers, ')
          ..write('lastModified: $lastModified, ')
          ..write('maxStale: $maxStale, ')
          ..write('priority: $priority, ')
          ..write('responseDate: $responseDate, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }
}

class $_DioCacheTable extends _DioCache
    with TableInfo<$_DioCacheTable, _DioCacheData> {
  final GeneratedDatabase _db;
  final String? _alias;
  $_DioCacheTable(this._db, [this._alias]);
  @override
  late final GeneratedTextColumn key = _constructKey();
  GeneratedTextColumn _constructKey() {
    return GeneratedTextColumn('key', $tableName, false,
        $customConstraints: 'PRIMARY KEY');
  }

  @override
  late final GeneratedDateTimeColumn date = _constructDate();
  GeneratedDateTimeColumn _constructDate() {
    return GeneratedDateTimeColumn(
      'date',
      $tableName,
      true,
    );
  }

  @override
  late final GeneratedTextColumn cacheControl = _constructCacheControl();
  GeneratedTextColumn _constructCacheControl() {
    return GeneratedTextColumn(
      'cache_control',
      $tableName,
      true,
    );
  }

  @override
  late final GeneratedBlobColumn content = _constructContent();
  GeneratedBlobColumn _constructContent() {
    return GeneratedBlobColumn(
      'content',
      $tableName,
      true,
    );
  }

  @override
  late final GeneratedTextColumn eTag = _constructETag();
  GeneratedTextColumn _constructETag() {
    return GeneratedTextColumn(
      'e_tag',
      $tableName,
      true,
    );
  }

  @override
  late final GeneratedDateTimeColumn expires = _constructExpires();
  GeneratedDateTimeColumn _constructExpires() {
    return GeneratedDateTimeColumn(
      'expires',
      $tableName,
      true,
    );
  }

  @override
  late final GeneratedBlobColumn headers = _constructHeaders();
  GeneratedBlobColumn _constructHeaders() {
    return GeneratedBlobColumn(
      'headers',
      $tableName,
      true,
    );
  }

  @override
  late final GeneratedTextColumn lastModified = _constructLastModified();
  GeneratedTextColumn _constructLastModified() {
    return GeneratedTextColumn(
      'last_modified',
      $tableName,
      true,
    );
  }

  @override
  late final GeneratedDateTimeColumn maxStale = _constructMaxStale();
  GeneratedDateTimeColumn _constructMaxStale() {
    return GeneratedDateTimeColumn(
      'max_stale',
      $tableName,
      true,
    );
  }

  @override
  late final GeneratedIntColumn priority = _constructPriority();
  GeneratedIntColumn _constructPriority() {
    return GeneratedIntColumn(
      'priority',
      $tableName,
      false,
    );
  }

  @override
  late final GeneratedDateTimeColumn responseDate = _constructResponseDate();
  GeneratedDateTimeColumn _constructResponseDate() {
    return GeneratedDateTimeColumn(
      'response_date',
      $tableName,
      false,
    );
  }

  @override
  late final GeneratedTextColumn url = _constructUrl();
  GeneratedTextColumn _constructUrl() {
    return GeneratedTextColumn(
      'url',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        key,
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
  $_DioCacheTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'dio_cache';
  @override
  final String actualTableName = 'dio_cache';
  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  _DioCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return _DioCacheData.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $_DioCacheTable createAlias(String alias) {
    return $_DioCacheTable(_db, alias);
  }
}

abstract class _$DioCacheDatabase extends GeneratedDatabase {
  _$DioCacheDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $_DioCacheTable dioCache = $_DioCacheTable(this);
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
  $_DioCacheTable get dioCache => attachedDatabase.dioCache;
}
