import 'dart:async';

import 'package:expense_tracker/constants/db_constant.dart';
import 'package:path/path.dart' as path_name;
import 'package:sqflite/sqflite.dart';

class DBService {
  static final DBService _instance = DBService._internal();

  factory DBService() => _instance;

  DBService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('expense_tracker.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = path_name.join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${TableNames.account} (
        ${AccountFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AccountFields.name} TEXT NOT NULL,
        ${AccountFields.balance} REAL DEFAULT 0,
        ${AccountFields.createdAt} TEXT DEFAULT CURRENT_TIMESTAMP,
        ${AccountFields.updatedAt} TEXT DEFAULT CURRENT_TIMESTAMP,
        ${AccountFields.isDeleted} INTEGER DEFAULT 0,
        ${AccountFields.isSynced} INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE ${TableNames.category} (
        ${CategoryFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${CategoryFields.name} TEXT NOT NULL,
        ${CategoryFields.type} TEXT NOT NULL,
        ${CategoryFields.icon} TEXT,
        ${CategoryFields.color} TEXT,
        ${CategoryFields.createdAt} TEXT DEFAULT CURRENT_TIMESTAMP,
        ${CategoryFields.updatedAt} TEXT DEFAULT CURRENT_TIMESTAMP,
        ${CategoryFields.isDeleted} INTEGER DEFAULT 0,
        ${CategoryFields.isSynced} INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE ${TableNames.transaction} (
        ${TransactionFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TransactionFields.userId} TEXT,
        ${TransactionFields.categoryId} INTEGER,
        ${TransactionFields.accountId} INTEGER,
        ${TransactionFields.amount} REAL,
        ${TransactionFields.type} TEXT,
        ${TransactionFields.note} TEXT,
        ${TransactionFields.date} TEXT,
        ${TransactionFields.attachments} TEXT,
        ${TransactionFields.createdAt} TEXT DEFAULT CURRENT_TIMESTAMP,
        ${TransactionFields.updatedAt} TEXT DEFAULT CURRENT_TIMESTAMP,
        ${TransactionFields.isDeleted} INTEGER DEFAULT 0,
        ${TransactionFields.isSynced} INTEGER DEFAULT 0,
        FOREIGN KEY (${TransactionFields.categoryId}) REFERENCES ${TableNames.category} (${CategoryFields.id}),
        FOREIGN KEY (${TransactionFields.accountId}) REFERENCES ${TableNames.account} (${AccountFields.id})
      );
    ''');
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String whereField,
    dynamic whereValue,
  ) async {
    final db = await database;
    data['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      table,
      data,
      where: '$whereField = ?',
      whereArgs: [whereValue],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> softDelete(
    String table,
    String whereField,
    dynamic whereValue,
  ) async {
    final db = await database;
    return await db.update(
      table,
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: '$whereField = ?',
      whereArgs: [whereValue],
    );
  }

  Future<int> delete(
    String table,
    String whereField,
    dynamic whereValue,
  ) async {
    final db = await database;
    return await db.delete(
      table,
      where: '$whereField = ?',
      whereArgs: [whereValue],
    );
  }

  Future<Map<String, dynamic>?> getById(
    String table,
    String idField,
    dynamic id,
  ) async {
    final db = await database;
    final result = await db.query(
      table,
      where: '$idField = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS ${TableNames.transaction}');
    await db.execute('DROP TABLE IF EXISTS ${TableNames.category}');
    await db.execute('DROP TABLE IF EXISTS ${TableNames.account}');
    await _onCreate(db, 1);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  static Map<String, dynamic> buildSelectQuery({
    required String table,
    List<String>? columns,
    Map<String, dynamic>? where,
    String? orderBy,
    bool orderDesc = false,
    int? limit,
    int? offset,
  }) {
    final buffer = StringBuffer();
    final args = <dynamic>[];

    buffer.write('SELECT ');
    if (columns != null && columns.isNotEmpty) {
      buffer.write(columns.join(', '));
    } else {
      buffer.write('*');
    }

    buffer.write(' FROM $table');

    if (where != null && where.isNotEmpty) {
      final conditions = <String>[];

      where.forEach((key, value) {
        if (key.contains('LIKE')) {
          conditions.add('$key ?');
          args.add('%$value%');
        } else if (key.contains('IN') && value is List) {
          final placeholders = List.filled(value.length, '?').join(', ');
          conditions.add('$key ($placeholders)');
          args.addAll(value);
        } else if (key.contains('>') ||
            key.contains('<') ||
            key.contains('!=')) {
          conditions.add('$key ?');
          args.add(value);
        } else {
          conditions.add('$key = ?');
          args.add(value);
        }
      });

      buffer.write(' WHERE ${conditions.join(' AND ')}');
    }

    if (orderBy != null && orderBy.isNotEmpty) {
      buffer.write(' ORDER BY $orderBy');
      if (orderDesc) buffer.write(' DESC');
    }

    if (limit != null) buffer.write(' LIMIT $limit');
    if (offset != null) buffer.write(' OFFSET $offset');

    buffer.write(';');

    return {'query': buffer.toString(), 'args': args};
  }
}
