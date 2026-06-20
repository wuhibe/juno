// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ConnectionsTable extends Connections
    with TableInfo<$ConnectionsTable, ConnectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConnectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _databaseMeta = const VerificationMeta(
    'database',
  );
  @override
  late final GeneratedColumn<String> database = GeneratedColumn<String>(
    'database',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sslModeMeta = const VerificationMeta(
    'sslMode',
  );
  @override
  late final GeneratedColumn<String> sslMode = GeneratedColumn<String>(
    'ssl_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readOnlyMeta = const VerificationMeta(
    'readOnly',
  );
  @override
  late final GeneratedColumn<bool> readOnly = GeneratedColumn<bool>(
    'read_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read_only" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _colorTagMeta = const VerificationMeta(
    'colorTag',
  );
  @override
  late final GeneratedColumn<String> colorTag = GeneratedColumn<String>(
    'color_tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _environmentMeta = const VerificationMeta(
    'environment',
  );
  @override
  late final GeneratedColumn<String> environment = GeneratedColumn<String>(
    'environment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    host,
    port,
    database,
    username,
    sslMode,
    readOnly,
    colorTag,
    environment,
    sortOrder,
    createdAt,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'connections';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConnectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    } else if (isInserting) {
      context.missing(_portMeta);
    }
    if (data.containsKey('database')) {
      context.handle(
        _databaseMeta,
        database.isAcceptableOrUnknown(data['database']!, _databaseMeta),
      );
    } else if (isInserting) {
      context.missing(_databaseMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('ssl_mode')) {
      context.handle(
        _sslModeMeta,
        sslMode.isAcceptableOrUnknown(data['ssl_mode']!, _sslModeMeta),
      );
    } else if (isInserting) {
      context.missing(_sslModeMeta);
    }
    if (data.containsKey('read_only')) {
      context.handle(
        _readOnlyMeta,
        readOnly.isAcceptableOrUnknown(data['read_only']!, _readOnlyMeta),
      );
    }
    if (data.containsKey('color_tag')) {
      context.handle(
        _colorTagMeta,
        colorTag.isAcceptableOrUnknown(data['color_tag']!, _colorTagMeta),
      );
    }
    if (data.containsKey('environment')) {
      context.handle(
        _environmentMeta,
        environment.isAcceptableOrUnknown(
          data['environment']!,
          _environmentMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConnectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConnectionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      database: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}database'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      sslMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ssl_mode'],
      )!,
      readOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}read_only'],
      )!,
      colorTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_tag'],
      ),
      environment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}environment'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
    );
  }

  @override
  $ConnectionsTable createAlias(String alias) {
    return $ConnectionsTable(attachedDatabase, alias);
  }
}

class ConnectionRow extends DataClass implements Insertable<ConnectionRow> {
  /// UUID primary key.
  final String id;

  /// User-facing name.
  final String name;

  /// `DatabaseKind.name` (persisted from day one for multi-engine support).
  final String kind;

  /// Hostname or IP.
  final String host;

  /// TCP port.
  final int port;

  /// Database/catalog name.
  final String database;

  /// Login role.
  final String username;

  /// `DbSslMode.name`.
  final String sslMode;

  /// Whether the connection enforces read-only mode.
  final bool readOnly;

  /// Optional color tag (hex or named) for the connection card.
  final String? colorTag;

  /// Optional `DbEnvironment.name` (dev/staging/prod).
  final String? environment;

  /// Manual ordering within the list.
  final int sortOrder;

  /// When the connection was created.
  final DateTime createdAt;

  /// When the connection was last successfully opened.
  final DateTime? lastUsedAt;
  const ConnectionRow({
    required this.id,
    required this.name,
    required this.kind,
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.sslMode,
    required this.readOnly,
    this.colorTag,
    this.environment,
    required this.sortOrder,
    required this.createdAt,
    this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['host'] = Variable<String>(host);
    map['port'] = Variable<int>(port);
    map['database'] = Variable<String>(database);
    map['username'] = Variable<String>(username);
    map['ssl_mode'] = Variable<String>(sslMode);
    map['read_only'] = Variable<bool>(readOnly);
    if (!nullToAbsent || colorTag != null) {
      map['color_tag'] = Variable<String>(colorTag);
    }
    if (!nullToAbsent || environment != null) {
      map['environment'] = Variable<String>(environment);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    return map;
  }

  ConnectionsCompanion toCompanion(bool nullToAbsent) {
    return ConnectionsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      host: Value(host),
      port: Value(port),
      database: Value(database),
      username: Value(username),
      sslMode: Value(sslMode),
      readOnly: Value(readOnly),
      colorTag: colorTag == null && nullToAbsent
          ? const Value.absent()
          : Value(colorTag),
      environment: environment == null && nullToAbsent
          ? const Value.absent()
          : Value(environment),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
    );
  }

  factory ConnectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConnectionRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      host: serializer.fromJson<String>(json['host']),
      port: serializer.fromJson<int>(json['port']),
      database: serializer.fromJson<String>(json['database']),
      username: serializer.fromJson<String>(json['username']),
      sslMode: serializer.fromJson<String>(json['sslMode']),
      readOnly: serializer.fromJson<bool>(json['readOnly']),
      colorTag: serializer.fromJson<String?>(json['colorTag']),
      environment: serializer.fromJson<String?>(json['environment']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'host': serializer.toJson<String>(host),
      'port': serializer.toJson<int>(port),
      'database': serializer.toJson<String>(database),
      'username': serializer.toJson<String>(username),
      'sslMode': serializer.toJson<String>(sslMode),
      'readOnly': serializer.toJson<bool>(readOnly),
      'colorTag': serializer.toJson<String?>(colorTag),
      'environment': serializer.toJson<String?>(environment),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
    };
  }

  ConnectionRow copyWith({
    String? id,
    String? name,
    String? kind,
    String? host,
    int? port,
    String? database,
    String? username,
    String? sslMode,
    bool? readOnly,
    Value<String?> colorTag = const Value.absent(),
    Value<String?> environment = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    Value<DateTime?> lastUsedAt = const Value.absent(),
  }) => ConnectionRow(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    host: host ?? this.host,
    port: port ?? this.port,
    database: database ?? this.database,
    username: username ?? this.username,
    sslMode: sslMode ?? this.sslMode,
    readOnly: readOnly ?? this.readOnly,
    colorTag: colorTag.present ? colorTag.value : this.colorTag,
    environment: environment.present ? environment.value : this.environment,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
  );
  ConnectionRow copyWithCompanion(ConnectionsCompanion data) {
    return ConnectionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      host: data.host.present ? data.host.value : this.host,
      port: data.port.present ? data.port.value : this.port,
      database: data.database.present ? data.database.value : this.database,
      username: data.username.present ? data.username.value : this.username,
      sslMode: data.sslMode.present ? data.sslMode.value : this.sslMode,
      readOnly: data.readOnly.present ? data.readOnly.value : this.readOnly,
      colorTag: data.colorTag.present ? data.colorTag.value : this.colorTag,
      environment: data.environment.present
          ? data.environment.value
          : this.environment,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('database: $database, ')
          ..write('username: $username, ')
          ..write('sslMode: $sslMode, ')
          ..write('readOnly: $readOnly, ')
          ..write('colorTag: $colorTag, ')
          ..write('environment: $environment, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    host,
    port,
    database,
    username,
    sslMode,
    readOnly,
    colorTag,
    environment,
    sortOrder,
    createdAt,
    lastUsedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConnectionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.host == this.host &&
          other.port == this.port &&
          other.database == this.database &&
          other.username == this.username &&
          other.sslMode == this.sslMode &&
          other.readOnly == this.readOnly &&
          other.colorTag == this.colorTag &&
          other.environment == this.environment &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt);
}

class ConnectionsCompanion extends UpdateCompanion<ConnectionRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> host;
  final Value<int> port;
  final Value<String> database;
  final Value<String> username;
  final Value<String> sslMode;
  final Value<bool> readOnly;
  final Value<String?> colorTag;
  final Value<String?> environment;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastUsedAt;
  final Value<int> rowid;
  const ConnectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.host = const Value.absent(),
    this.port = const Value.absent(),
    this.database = const Value.absent(),
    this.username = const Value.absent(),
    this.sslMode = const Value.absent(),
    this.readOnly = const Value.absent(),
    this.colorTag = const Value.absent(),
    this.environment = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConnectionsCompanion.insert({
    required String id,
    required String name,
    required String kind,
    required String host,
    required int port,
    required String database,
    required String username,
    required String sslMode,
    this.readOnly = const Value.absent(),
    this.colorTag = const Value.absent(),
    this.environment = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       host = Value(host),
       port = Value(port),
       database = Value(database),
       username = Value(username),
       sslMode = Value(sslMode),
       createdAt = Value(createdAt);
  static Insertable<ConnectionRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? host,
    Expression<int>? port,
    Expression<String>? database,
    Expression<String>? username,
    Expression<String>? sslMode,
    Expression<bool>? readOnly,
    Expression<String>? colorTag,
    Expression<String>? environment,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (database != null) 'database': database,
      if (username != null) 'username': username,
      if (sslMode != null) 'ssl_mode': sslMode,
      if (readOnly != null) 'read_only': readOnly,
      if (colorTag != null) 'color_tag': colorTag,
      if (environment != null) 'environment': environment,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConnectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? host,
    Value<int>? port,
    Value<String>? database,
    Value<String>? username,
    Value<String>? sslMode,
    Value<bool>? readOnly,
    Value<String?>? colorTag,
    Value<String?>? environment,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return ConnectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      host: host ?? this.host,
      port: port ?? this.port,
      database: database ?? this.database,
      username: username ?? this.username,
      sslMode: sslMode ?? this.sslMode,
      readOnly: readOnly ?? this.readOnly,
      colorTag: colorTag ?? this.colorTag,
      environment: environment ?? this.environment,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (database.present) {
      map['database'] = Variable<String>(database.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (sslMode.present) {
      map['ssl_mode'] = Variable<String>(sslMode.value);
    }
    if (readOnly.present) {
      map['read_only'] = Variable<bool>(readOnly.value);
    }
    if (colorTag.present) {
      map['color_tag'] = Variable<String>(colorTag.value);
    }
    if (environment.present) {
      map['environment'] = Variable<String>(environment.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConnectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('database: $database, ')
          ..write('username: $username, ')
          ..write('sslMode: $sslMode, ')
          ..write('readOnly: $readOnly, ')
          ..write('colorTag: $colorTag, ')
          ..write('environment: $environment, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueryHistoryEntriesTable extends QueryHistoryEntries
    with TableInfo<$QueryHistoryEntriesTable, QueryHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueryHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _connectionIdMeta = const VerificationMeta(
    'connectionId',
  );
  @override
  late final GeneratedColumn<String> connectionId = GeneratedColumn<String>(
    'connection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES connections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sqlTextMeta = const VerificationMeta(
    'sqlText',
  );
  @override
  late final GeneratedColumn<String> sqlText = GeneratedColumn<String>(
    'sql_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowCountMeta = const VerificationMeta(
    'rowCount',
  );
  @override
  late final GeneratedColumn<int> rowCount = GeneratedColumn<int>(
    'row_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _successMeta = const VerificationMeta(
    'success',
  );
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
    'success',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("success" IN (0, 1))',
    ),
  );
  static const VerificationMeta _errorSummaryMeta = const VerificationMeta(
    'errorSummary',
  );
  @override
  late final GeneratedColumn<String> errorSummary = GeneratedColumn<String>(
    'error_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    connectionId,
    sqlText,
    startedAt,
    elapsedMs,
    rowCount,
    success,
    errorSummary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'query_history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueryHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('connection_id')) {
      context.handle(
        _connectionIdMeta,
        connectionId.isAcceptableOrUnknown(
          data['connection_id']!,
          _connectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectionIdMeta);
    }
    if (data.containsKey('sql_text')) {
      context.handle(
        _sqlTextMeta,
        sqlText.isAcceptableOrUnknown(data['sql_text']!, _sqlTextMeta),
      );
    } else if (isInserting) {
      context.missing(_sqlTextMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_elapsedMsMeta);
    }
    if (data.containsKey('row_count')) {
      context.handle(
        _rowCountMeta,
        rowCount.isAcceptableOrUnknown(data['row_count']!, _rowCountMeta),
      );
    }
    if (data.containsKey('success')) {
      context.handle(
        _successMeta,
        success.isAcceptableOrUnknown(data['success']!, _successMeta),
      );
    } else if (isInserting) {
      context.missing(_successMeta);
    }
    if (data.containsKey('error_summary')) {
      context.handle(
        _errorSummaryMeta,
        errorSummary.isAcceptableOrUnknown(
          data['error_summary']!,
          _errorSummaryMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueryHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueryHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      connectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}connection_id'],
      )!,
      sqlText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sql_text'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      elapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_ms'],
      )!,
      rowCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_count'],
      ),
      success: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}success'],
      )!,
      errorSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_summary'],
      ),
    );
  }

  @override
  $QueryHistoryEntriesTable createAlias(String alias) {
    return $QueryHistoryEntriesTable(attachedDatabase, alias);
  }
}

class QueryHistoryRow extends DataClass implements Insertable<QueryHistoryRow> {
  /// Auto-increment primary key.
  final int id;

  /// Owning connection; rows cascade-delete with the connection.
  final String connectionId;

  /// The SQL that was run.
  final String sqlText;

  /// When execution started.
  final DateTime startedAt;

  /// Server round-trip time, in milliseconds.
  final int elapsedMs;

  /// Rows returned, when known.
  final int? rowCount;

  /// Whether the statement succeeded.
  final bool success;

  /// A short, user-safe error summary when [success] is false.
  final String? errorSummary;
  const QueryHistoryRow({
    required this.id,
    required this.connectionId,
    required this.sqlText,
    required this.startedAt,
    required this.elapsedMs,
    this.rowCount,
    required this.success,
    this.errorSummary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['connection_id'] = Variable<String>(connectionId);
    map['sql_text'] = Variable<String>(sqlText);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    if (!nullToAbsent || rowCount != null) {
      map['row_count'] = Variable<int>(rowCount);
    }
    map['success'] = Variable<bool>(success);
    if (!nullToAbsent || errorSummary != null) {
      map['error_summary'] = Variable<String>(errorSummary);
    }
    return map;
  }

  QueryHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return QueryHistoryEntriesCompanion(
      id: Value(id),
      connectionId: Value(connectionId),
      sqlText: Value(sqlText),
      startedAt: Value(startedAt),
      elapsedMs: Value(elapsedMs),
      rowCount: rowCount == null && nullToAbsent
          ? const Value.absent()
          : Value(rowCount),
      success: Value(success),
      errorSummary: errorSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(errorSummary),
    );
  }

  factory QueryHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueryHistoryRow(
      id: serializer.fromJson<int>(json['id']),
      connectionId: serializer.fromJson<String>(json['connectionId']),
      sqlText: serializer.fromJson<String>(json['sqlText']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      rowCount: serializer.fromJson<int?>(json['rowCount']),
      success: serializer.fromJson<bool>(json['success']),
      errorSummary: serializer.fromJson<String?>(json['errorSummary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'connectionId': serializer.toJson<String>(connectionId),
      'sqlText': serializer.toJson<String>(sqlText),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'rowCount': serializer.toJson<int?>(rowCount),
      'success': serializer.toJson<bool>(success),
      'errorSummary': serializer.toJson<String?>(errorSummary),
    };
  }

  QueryHistoryRow copyWith({
    int? id,
    String? connectionId,
    String? sqlText,
    DateTime? startedAt,
    int? elapsedMs,
    Value<int?> rowCount = const Value.absent(),
    bool? success,
    Value<String?> errorSummary = const Value.absent(),
  }) => QueryHistoryRow(
    id: id ?? this.id,
    connectionId: connectionId ?? this.connectionId,
    sqlText: sqlText ?? this.sqlText,
    startedAt: startedAt ?? this.startedAt,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    rowCount: rowCount.present ? rowCount.value : this.rowCount,
    success: success ?? this.success,
    errorSummary: errorSummary.present ? errorSummary.value : this.errorSummary,
  );
  QueryHistoryRow copyWithCompanion(QueryHistoryEntriesCompanion data) {
    return QueryHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      connectionId: data.connectionId.present
          ? data.connectionId.value
          : this.connectionId,
      sqlText: data.sqlText.present ? data.sqlText.value : this.sqlText,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      rowCount: data.rowCount.present ? data.rowCount.value : this.rowCount,
      success: data.success.present ? data.success.value : this.success,
      errorSummary: data.errorSummary.present
          ? data.errorSummary.value
          : this.errorSummary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueryHistoryRow(')
          ..write('id: $id, ')
          ..write('connectionId: $connectionId, ')
          ..write('sqlText: $sqlText, ')
          ..write('startedAt: $startedAt, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('rowCount: $rowCount, ')
          ..write('success: $success, ')
          ..write('errorSummary: $errorSummary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    connectionId,
    sqlText,
    startedAt,
    elapsedMs,
    rowCount,
    success,
    errorSummary,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueryHistoryRow &&
          other.id == this.id &&
          other.connectionId == this.connectionId &&
          other.sqlText == this.sqlText &&
          other.startedAt == this.startedAt &&
          other.elapsedMs == this.elapsedMs &&
          other.rowCount == this.rowCount &&
          other.success == this.success &&
          other.errorSummary == this.errorSummary);
}

class QueryHistoryEntriesCompanion extends UpdateCompanion<QueryHistoryRow> {
  final Value<int> id;
  final Value<String> connectionId;
  final Value<String> sqlText;
  final Value<DateTime> startedAt;
  final Value<int> elapsedMs;
  final Value<int?> rowCount;
  final Value<bool> success;
  final Value<String?> errorSummary;
  const QueryHistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.connectionId = const Value.absent(),
    this.sqlText = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.rowCount = const Value.absent(),
    this.success = const Value.absent(),
    this.errorSummary = const Value.absent(),
  });
  QueryHistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String connectionId,
    required String sqlText,
    required DateTime startedAt,
    required int elapsedMs,
    this.rowCount = const Value.absent(),
    required bool success,
    this.errorSummary = const Value.absent(),
  }) : connectionId = Value(connectionId),
       sqlText = Value(sqlText),
       startedAt = Value(startedAt),
       elapsedMs = Value(elapsedMs),
       success = Value(success);
  static Insertable<QueryHistoryRow> custom({
    Expression<int>? id,
    Expression<String>? connectionId,
    Expression<String>? sqlText,
    Expression<DateTime>? startedAt,
    Expression<int>? elapsedMs,
    Expression<int>? rowCount,
    Expression<bool>? success,
    Expression<String>? errorSummary,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (connectionId != null) 'connection_id': connectionId,
      if (sqlText != null) 'sql_text': sqlText,
      if (startedAt != null) 'started_at': startedAt,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (rowCount != null) 'row_count': rowCount,
      if (success != null) 'success': success,
      if (errorSummary != null) 'error_summary': errorSummary,
    });
  }

  QueryHistoryEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? connectionId,
    Value<String>? sqlText,
    Value<DateTime>? startedAt,
    Value<int>? elapsedMs,
    Value<int?>? rowCount,
    Value<bool>? success,
    Value<String?>? errorSummary,
  }) {
    return QueryHistoryEntriesCompanion(
      id: id ?? this.id,
      connectionId: connectionId ?? this.connectionId,
      sqlText: sqlText ?? this.sqlText,
      startedAt: startedAt ?? this.startedAt,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      rowCount: rowCount ?? this.rowCount,
      success: success ?? this.success,
      errorSummary: errorSummary ?? this.errorSummary,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (connectionId.present) {
      map['connection_id'] = Variable<String>(connectionId.value);
    }
    if (sqlText.present) {
      map['sql_text'] = Variable<String>(sqlText.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (rowCount.present) {
      map['row_count'] = Variable<int>(rowCount.value);
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (errorSummary.present) {
      map['error_summary'] = Variable<String>(errorSummary.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueryHistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('connectionId: $connectionId, ')
          ..write('sqlText: $sqlText, ')
          ..write('startedAt: $startedAt, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('rowCount: $rowCount, ')
          ..write('success: $success, ')
          ..write('errorSummary: $errorSummary')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConnectionsTable connections = $ConnectionsTable(this);
  late final $QueryHistoryEntriesTable queryHistoryEntries =
      $QueryHistoryEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    connections,
    queryHistoryEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'connections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('query_history_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ConnectionsTableCreateCompanionBuilder =
    ConnectionsCompanion Function({
      required String id,
      required String name,
      required String kind,
      required String host,
      required int port,
      required String database,
      required String username,
      required String sslMode,
      Value<bool> readOnly,
      Value<String?> colorTag,
      Value<String?> environment,
      Value<int> sortOrder,
      required DateTime createdAt,
      Value<DateTime?> lastUsedAt,
      Value<int> rowid,
    });
typedef $$ConnectionsTableUpdateCompanionBuilder =
    ConnectionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> kind,
      Value<String> host,
      Value<int> port,
      Value<String> database,
      Value<String> username,
      Value<String> sslMode,
      Value<bool> readOnly,
      Value<String?> colorTag,
      Value<String?> environment,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime?> lastUsedAt,
      Value<int> rowid,
    });

final class $$ConnectionsTableReferences
    extends BaseReferences<_$AppDatabase, $ConnectionsTable, ConnectionRow> {
  $$ConnectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QueryHistoryEntriesTable, List<QueryHistoryRow>>
  _queryHistoryEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.queryHistoryEntries,
        aliasName: 'connections__id__query_history_entries__connection_id',
      );

  $$QueryHistoryEntriesTableProcessedTableManager get queryHistoryEntriesRefs {
    final manager = $$QueryHistoryEntriesTableTableManager(
      $_db,
      $_db.queryHistoryEntries,
    ).filter((f) => f.connectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _queryHistoryEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConnectionsTableFilterComposer
    extends Composer<_$AppDatabase, $ConnectionsTable> {
  $$ConnectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get database => $composableBuilder(
    column: $table.database,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sslMode => $composableBuilder(
    column: $table.sslMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get readOnly => $composableBuilder(
    column: $table.readOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorTag => $composableBuilder(
    column: $table.colorTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> queryHistoryEntriesRefs(
    Expression<bool> Function($$QueryHistoryEntriesTableFilterComposer f) f,
  ) {
    final $$QueryHistoryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queryHistoryEntries,
      getReferencedColumn: (t) => t.connectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueryHistoryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.queryHistoryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConnectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConnectionsTable> {
  $$ConnectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get database => $composableBuilder(
    column: $table.database,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sslMode => $composableBuilder(
    column: $table.sslMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get readOnly => $composableBuilder(
    column: $table.readOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorTag => $composableBuilder(
    column: $table.colorTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConnectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConnectionsTable> {
  $$ConnectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get database =>
      $composableBuilder(column: $table.database, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get sslMode =>
      $composableBuilder(column: $table.sslMode, builder: (column) => column);

  GeneratedColumn<bool> get readOnly =>
      $composableBuilder(column: $table.readOnly, builder: (column) => column);

  GeneratedColumn<String> get colorTag =>
      $composableBuilder(column: $table.colorTag, builder: (column) => column);

  GeneratedColumn<String> get environment => $composableBuilder(
    column: $table.environment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  Expression<T> queryHistoryEntriesRefs<T extends Object>(
    Expression<T> Function($$QueryHistoryEntriesTableAnnotationComposer a) f,
  ) {
    final $$QueryHistoryEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.queryHistoryEntries,
          getReferencedColumn: (t) => t.connectionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$QueryHistoryEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.queryHistoryEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ConnectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConnectionsTable,
          ConnectionRow,
          $$ConnectionsTableFilterComposer,
          $$ConnectionsTableOrderingComposer,
          $$ConnectionsTableAnnotationComposer,
          $$ConnectionsTableCreateCompanionBuilder,
          $$ConnectionsTableUpdateCompanionBuilder,
          (ConnectionRow, $$ConnectionsTableReferences),
          ConnectionRow,
          PrefetchHooks Function({bool queryHistoryEntriesRefs})
        > {
  $$ConnectionsTableTableManager(_$AppDatabase db, $ConnectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConnectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConnectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConnectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<String> database = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> sslMode = const Value.absent(),
                Value<bool> readOnly = const Value.absent(),
                Value<String?> colorTag = const Value.absent(),
                Value<String?> environment = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConnectionsCompanion(
                id: id,
                name: name,
                kind: kind,
                host: host,
                port: port,
                database: database,
                username: username,
                sslMode: sslMode,
                readOnly: readOnly,
                colorTag: colorTag,
                environment: environment,
                sortOrder: sortOrder,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String kind,
                required String host,
                required int port,
                required String database,
                required String username,
                required String sslMode,
                Value<bool> readOnly = const Value.absent(),
                Value<String?> colorTag = const Value.absent(),
                Value<String?> environment = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConnectionsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                host: host,
                port: port,
                database: database,
                username: username,
                sslMode: sslMode,
                readOnly: readOnly,
                colorTag: colorTag,
                environment: environment,
                sortOrder: sortOrder,
                createdAt: createdAt,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConnectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({queryHistoryEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (queryHistoryEntriesRefs) db.queryHistoryEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (queryHistoryEntriesRefs)
                    await $_getPrefetchedData<
                      ConnectionRow,
                      $ConnectionsTable,
                      QueryHistoryRow
                    >(
                      currentTable: table,
                      referencedTable: $$ConnectionsTableReferences
                          ._queryHistoryEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ConnectionsTableReferences(
                            db,
                            table,
                            p0,
                          ).queryHistoryEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.connectionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ConnectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConnectionsTable,
      ConnectionRow,
      $$ConnectionsTableFilterComposer,
      $$ConnectionsTableOrderingComposer,
      $$ConnectionsTableAnnotationComposer,
      $$ConnectionsTableCreateCompanionBuilder,
      $$ConnectionsTableUpdateCompanionBuilder,
      (ConnectionRow, $$ConnectionsTableReferences),
      ConnectionRow,
      PrefetchHooks Function({bool queryHistoryEntriesRefs})
    >;
typedef $$QueryHistoryEntriesTableCreateCompanionBuilder =
    QueryHistoryEntriesCompanion Function({
      Value<int> id,
      required String connectionId,
      required String sqlText,
      required DateTime startedAt,
      required int elapsedMs,
      Value<int?> rowCount,
      required bool success,
      Value<String?> errorSummary,
    });
typedef $$QueryHistoryEntriesTableUpdateCompanionBuilder =
    QueryHistoryEntriesCompanion Function({
      Value<int> id,
      Value<String> connectionId,
      Value<String> sqlText,
      Value<DateTime> startedAt,
      Value<int> elapsedMs,
      Value<int?> rowCount,
      Value<bool> success,
      Value<String?> errorSummary,
    });

final class $$QueryHistoryEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $QueryHistoryEntriesTable,
          QueryHistoryRow
        > {
  $$QueryHistoryEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ConnectionsTable _connectionIdTable(_$AppDatabase db) => db
      .connections
      .createAlias('query_history_entries__connection_id__connections__id');

  $$ConnectionsTableProcessedTableManager get connectionId {
    final $_column = $_itemColumn<String>('connection_id')!;

    final manager = $$ConnectionsTableTableManager(
      $_db,
      $_db.connections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_connectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QueryHistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $QueryHistoryEntriesTable> {
  $$QueryHistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sqlText => $composableBuilder(
    column: $table.sqlText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowCount => $composableBuilder(
    column: $table.rowCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorSummary => $composableBuilder(
    column: $table.errorSummary,
    builder: (column) => ColumnFilters(column),
  );

  $$ConnectionsTableFilterComposer get connectionId {
    final $$ConnectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableFilterComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueryHistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $QueryHistoryEntriesTable> {
  $$QueryHistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sqlText => $composableBuilder(
    column: $table.sqlText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowCount => $composableBuilder(
    column: $table.rowCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorSummary => $composableBuilder(
    column: $table.errorSummary,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConnectionsTableOrderingComposer get connectionId {
    final $$ConnectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableOrderingComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueryHistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueryHistoryEntriesTable> {
  $$QueryHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sqlText =>
      $composableBuilder(column: $table.sqlText, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<int> get rowCount =>
      $composableBuilder(column: $table.rowCount, builder: (column) => column);

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<String> get errorSummary => $composableBuilder(
    column: $table.errorSummary,
    builder: (column) => column,
  );

  $$ConnectionsTableAnnotationComposer get connectionId {
    final $$ConnectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.connectionId,
      referencedTable: $db.connections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConnectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.connections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueryHistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueryHistoryEntriesTable,
          QueryHistoryRow,
          $$QueryHistoryEntriesTableFilterComposer,
          $$QueryHistoryEntriesTableOrderingComposer,
          $$QueryHistoryEntriesTableAnnotationComposer,
          $$QueryHistoryEntriesTableCreateCompanionBuilder,
          $$QueryHistoryEntriesTableUpdateCompanionBuilder,
          (QueryHistoryRow, $$QueryHistoryEntriesTableReferences),
          QueryHistoryRow,
          PrefetchHooks Function({bool connectionId})
        > {
  $$QueryHistoryEntriesTableTableManager(
    _$AppDatabase db,
    $QueryHistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueryHistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueryHistoryEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$QueryHistoryEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> connectionId = const Value.absent(),
                Value<String> sqlText = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<int?> rowCount = const Value.absent(),
                Value<bool> success = const Value.absent(),
                Value<String?> errorSummary = const Value.absent(),
              }) => QueryHistoryEntriesCompanion(
                id: id,
                connectionId: connectionId,
                sqlText: sqlText,
                startedAt: startedAt,
                elapsedMs: elapsedMs,
                rowCount: rowCount,
                success: success,
                errorSummary: errorSummary,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String connectionId,
                required String sqlText,
                required DateTime startedAt,
                required int elapsedMs,
                Value<int?> rowCount = const Value.absent(),
                required bool success,
                Value<String?> errorSummary = const Value.absent(),
              }) => QueryHistoryEntriesCompanion.insert(
                id: id,
                connectionId: connectionId,
                sqlText: sqlText,
                startedAt: startedAt,
                elapsedMs: elapsedMs,
                rowCount: rowCount,
                success: success,
                errorSummary: errorSummary,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QueryHistoryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({connectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (connectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.connectionId,
                                referencedTable:
                                    $$QueryHistoryEntriesTableReferences
                                        ._connectionIdTable(db),
                                referencedColumn:
                                    $$QueryHistoryEntriesTableReferences
                                        ._connectionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QueryHistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueryHistoryEntriesTable,
      QueryHistoryRow,
      $$QueryHistoryEntriesTableFilterComposer,
      $$QueryHistoryEntriesTableOrderingComposer,
      $$QueryHistoryEntriesTableAnnotationComposer,
      $$QueryHistoryEntriesTableCreateCompanionBuilder,
      $$QueryHistoryEntriesTableUpdateCompanionBuilder,
      (QueryHistoryRow, $$QueryHistoryEntriesTableReferences),
      QueryHistoryRow,
      PrefetchHooks Function({bool connectionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ConnectionsTableTableManager get connections =>
      $$ConnectionsTableTableManager(_db, _db.connections);
  $$QueryHistoryEntriesTableTableManager get queryHistoryEntries =>
      $$QueryHistoryEntriesTableTableManager(_db, _db.queryHistoryEntries);
}
