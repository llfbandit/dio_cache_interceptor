// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// DriftDatabaseGenerator
// **************************************************************************

// ignore_for_file: type=lint
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
  final DateTime? requestDate;
  final DateTime responseDate;
  final String url;
  const DioCacheData(
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
      this.requestDate,
      required this.responseDate,
      required this.url});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cacheKey'] = Variable<String>(cacheKey);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    if (!nullToAbsent || cacheControl != null) {
      map['cacheControl'] = Variable<String>(cacheControl);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<Uint8List>(content);
    }
    if (!nullToAbsent || eTag != null) {
      map['eTag'] = Variable<String>(eTag);
    }
    if (!nullToAbsent || expires != null) {
      map['expires'] = Variable<DateTime>(expires);
    }
    if (!nullToAbsent || headers != null) {
      map['headers'] = Variable<Uint8List>(headers);
    }
    if (!nullToAbsent || lastModified != null) {
      map['lastModified'] = Variable<String>(lastModified);
    }
    if (!nullToAbsent || maxStale != null) {
      map['maxStale'] = Variable<DateTime>(maxStale);
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || requestDate != null) {
      map['requestDate'] = Variable<DateTime>(requestDate);
    }
    map['responseDate'] = Variable<DateTime>(responseDate);
    map['url'] = Variable<String>(url);
    return map;
  }

  factory DioCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DioCacheData(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      date: serializer.fromJson<DateTime?>(json['date']),
      cacheControl: serializer.fromJson<String?>(json['cacheControl']),
      content: serializer.fromJson<Uint8List?>(json['content']),
      eTag: serializer.fromJson<String?>(json['eTag']),
      expires: serializer.fromJson<DateTime?>(json['expires']),
      headers: serializer.fromJson<Uint8List?>(json['headers']),
      lastModified: serializer.fromJson<String?>(json['lastModified']),
      maxStale: serializer.fromJson<DateTime?>(json['maxStale']),
      priority: serializer.fromJson<int>(json['priority']),
      requestDate: serializer.fromJson<DateTime?>(json['requestDate']),
      responseDate: serializer.fromJson<DateTime>(json['responseDate']),
      url: serializer.fromJson<String>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
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
      'requestDate': serializer.toJson<DateTime?>(requestDate),
      'responseDate': serializer.toJson<DateTime>(responseDate),
      'url': serializer.toJson<String>(url),
    };
  }

  DioCacheData copyWith(
          {String? cacheKey,
          Value<DateTime?> date = const Value.absent(),
          Value<String?> cacheControl = const Value.absent(),
          Value<Uint8List?> content = const Value.absent(),
          Value<String?> eTag = const Value.absent(),
          Value<DateTime?> expires = const Value.absent(),
          Value<Uint8List?> headers = const Value.absent(),
          Value<String?> lastModified = const Value.absent(),
          Value<DateTime?> maxStale = const Value.absent(),
          int? priority,
          Value<DateTime?> requestDate = const Value.absent(),
          DateTime? responseDate,
          String? url}) =>
      DioCacheData(
        cacheKey: cacheKey ?? this.cacheKey,
        date: date.present ? date.value : this.date,
        cacheControl:
            cacheControl.present ? cacheControl.value : this.cacheControl,
        content: content.present ? content.value : this.content,
        eTag: eTag.present ? eTag.value : this.eTag,
        expires: expires.present ? expires.value : this.expires,
        headers: headers.present ? headers.value : this.headers,
        lastModified:
            lastModified.present ? lastModified.value : this.lastModified,
        maxStale: maxStale.present ? maxStale.value : this.maxStale,
        priority: priority ?? this.priority,
        requestDate: requestDate.present ? requestDate.value : this.requestDate,
        responseDate: responseDate ?? this.responseDate,
        url: url ?? this.url,
      );
  @override
  String toString() {
    return (StringBuffer('DioCacheData(')
          ..write('cacheKey: $cacheKey, ')
          ..write('date: $date, ')
          ..write('cacheControl: $cacheControl, ')
          ..write('content: $content, ')
          ..write('eTag: $eTag, ')
          ..write('expires: $expires, ')
          ..write('headers: $headers, ')
          ..write('lastModified: $lastModified, ')
          ..write('maxStale: $maxStale, ')
          ..write('priority: $priority, ')
          ..write('requestDate: $requestDate, ')
          ..write('responseDate: $responseDate, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      requestDate,
      responseDate,
      url);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DioCacheData &&
          other.cacheKey == this.cacheKey &&
          other.date == this.date &&
          other.cacheControl == this.cacheControl &&
          other.content == this.content &&
          other.eTag == this.eTag &&
          other.expires == this.expires &&
          other.headers == this.headers &&
          other.lastModified == this.lastModified &&
          other.maxStale == this.maxStale &&
          other.priority == this.priority &&
          other.requestDate == this.requestDate &&
          other.responseDate == this.responseDate &&
          other.url == this.url);
}

class DioCacheCompanion extends UpdateCompanion<DioCacheData> {
  final Value<String> cacheKey;
  final Value<DateTime?> date;
  final Value<String?> cacheControl;
  final Value<Uint8List?> content;
  final Value<String?> eTag;
  final Value<DateTime?> expires;
  final Value<Uint8List?> headers;
  final Value<String?> lastModified;
  final Value<DateTime?> maxStale;
  final Value<int> priority;
  final Value<DateTime?> requestDate;
  final Value<DateTime> responseDate;
  final Value<String> url;
  const DioCacheCompanion({
    this.cacheKey = const Value.absent(),
    this.date = const Value.absent(),
    this.cacheControl = const Value.absent(),
    this.content = const Value.absent(),
    this.eTag = const Value.absent(),
    this.expires = const Value.absent(),
    this.headers = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.maxStale = const Value.absent(),
    this.priority = const Value.absent(),
    this.requestDate = const Value.absent(),
    this.responseDate = const Value.absent(),
    this.url = const Value.absent(),
  });
  DioCacheCompanion.insert({
    required String cacheKey,
    this.date = const Value.absent(),
    this.cacheControl = const Value.absent(),
    this.content = const Value.absent(),
    this.eTag = const Value.absent(),
    this.expires = const Value.absent(),
    this.headers = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.maxStale = const Value.absent(),
    required int priority,
    this.requestDate = const Value.absent(),
    required DateTime responseDate,
    required String url,
  })  : cacheKey = Value(cacheKey),
        priority = Value(priority),
        responseDate = Value(responseDate),
        url = Value(url);
  static Insertable<DioCacheData> custom({
    Expression<String>? cacheKey,
    Expression<DateTime>? date,
    Expression<String>? cacheControl,
    Expression<Uint8List>? content,
    Expression<String>? eTag,
    Expression<DateTime>? expires,
    Expression<Uint8List>? headers,
    Expression<String>? lastModified,
    Expression<DateTime>? maxStale,
    Expression<int>? priority,
    Expression<DateTime>? requestDate,
    Expression<DateTime>? responseDate,
    Expression<String>? url,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cacheKey': cacheKey,
      if (date != null) 'date': date,
      if (cacheControl != null) 'cacheControl': cacheControl,
      if (content != null) 'content': content,
      if (eTag != null) 'eTag': eTag,
      if (expires != null) 'expires': expires,
      if (headers != null) 'headers': headers,
      if (lastModified != null) 'lastModified': lastModified,
      if (maxStale != null) 'maxStale': maxStale,
      if (priority != null) 'priority': priority,
      if (requestDate != null) 'requestDate': requestDate,
      if (responseDate != null) 'responseDate': responseDate,
      if (url != null) 'url': url,
    });
  }

  DioCacheCompanion copyWith(
      {Value<String>? cacheKey,
      Value<DateTime?>? date,
      Value<String?>? cacheControl,
      Value<Uint8List?>? content,
      Value<String?>? eTag,
      Value<DateTime?>? expires,
      Value<Uint8List?>? headers,
      Value<String?>? lastModified,
      Value<DateTime?>? maxStale,
      Value<int>? priority,
      Value<DateTime?>? requestDate,
      Value<DateTime>? responseDate,
      Value<String>? url}) {
    return DioCacheCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      date: date ?? this.date,
      cacheControl: cacheControl ?? this.cacheControl,
      content: content ?? this.content,
      eTag: eTag ?? this.eTag,
      expires: expires ?? this.expires,
      headers: headers ?? this.headers,
      lastModified: lastModified ?? this.lastModified,
      maxStale: maxStale ?? this.maxStale,
      priority: priority ?? this.priority,
      requestDate: requestDate ?? this.requestDate,
      responseDate: responseDate ?? this.responseDate,
      url: url ?? this.url,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cacheKey'] = Variable<String>(cacheKey.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (cacheControl.present) {
      map['cacheControl'] = Variable<String>(cacheControl.value);
    }
    if (content.present) {
      map['content'] = Variable<Uint8List>(content.value);
    }
    if (eTag.present) {
      map['eTag'] = Variable<String>(eTag.value);
    }
    if (expires.present) {
      map['expires'] = Variable<DateTime>(expires.value);
    }
    if (headers.present) {
      map['headers'] = Variable<Uint8List>(headers.value);
    }
    if (lastModified.present) {
      map['lastModified'] = Variable<String>(lastModified.value);
    }
    if (maxStale.present) {
      map['maxStale'] = Variable<DateTime>(maxStale.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (requestDate.present) {
      map['requestDate'] = Variable<DateTime>(requestDate.value);
    }
    if (responseDate.present) {
      map['responseDate'] = Variable<DateTime>(responseDate.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DioCacheCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('date: $date, ')
          ..write('cacheControl: $cacheControl, ')
          ..write('content: $content, ')
          ..write('eTag: $eTag, ')
          ..write('expires: $expires, ')
          ..write('headers: $headers, ')
          ..write('lastModified: $lastModified, ')
          ..write('maxStale: $maxStale, ')
          ..write('priority: $priority, ')
          ..write('requestDate: $requestDate, ')
          ..write('responseDate: $responseDate, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }
}

class DioCache extends Table with TableInfo<DioCache, DioCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DioCache(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
      'cacheKey', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<String> cacheControl = GeneratedColumn<String>(
      'cacheControl', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<Uint8List> content = GeneratedColumn<Uint8List>(
      'content', aliasedName, true,
      type: DriftSqlType.blob,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<String> eTag = GeneratedColumn<String>(
      'eTag', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<DateTime> expires = GeneratedColumn<DateTime>(
      'expires', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<Uint8List> headers = GeneratedColumn<Uint8List>(
      'headers', aliasedName, true,
      type: DriftSqlType.blob,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<String> lastModified = GeneratedColumn<String>(
      'lastModified', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<DateTime> maxStale = GeneratedColumn<DateTime>(
      'maxStale', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<DateTime> requestDate = GeneratedColumn<DateTime>(
      'requestDate', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<DateTime> responseDate = GeneratedColumn<DateTime>(
      'responseDate', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
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
        requestDate,
        responseDate,
        url
      ];
  @override
  String get aliasedName => _alias ?? 'DioCache';
  @override
  String get actualTableName => 'DioCache';
  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  DioCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DioCacheData(
      cacheKey: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}cacheKey'])!,
      date: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date']),
      cacheControl: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}cacheControl']),
      content: attachedDatabase.options.types
          .read(DriftSqlType.blob, data['${effectivePrefix}content']),
      eTag: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}eTag']),
      expires: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires']),
      headers: attachedDatabase.options.types
          .read(DriftSqlType.blob, data['${effectivePrefix}headers']),
      lastModified: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}lastModified']),
      maxStale: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}maxStale']),
      priority: attachedDatabase.options.types
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      requestDate: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}requestDate']),
      responseDate: attachedDatabase.options.types
          .read(DriftSqlType.dateTime, data['${effectivePrefix}responseDate'])!,
      url: attachedDatabase.options.types
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
    );
  }

  @override
  DioCache createAlias(String alias) {
    return DioCache(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

abstract class _$DioCacheDatabase extends GeneratedDatabase {
  _$DioCacheDatabase(QueryExecutor e) : super(e);
  late final DioCache dioCache = DioCache(this);
  late final DioCacheDao dioCacheDao = DioCacheDao(this as DioCacheDatabase);
  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [dioCache];
}

// **************************************************************************
// DaoGenerator
// **************************************************************************

mixin _$DioCacheDaoMixin on DatabaseAccessor<DioCacheDatabase> {
  DioCache get dioCache => attachedDatabase.dioCache;
}
