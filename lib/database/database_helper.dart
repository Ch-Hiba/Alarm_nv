// database/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/alarm.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'alarms.db');
    return await openDatabase(
      path,
      version: 2, // Incrémenté pour la migration
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alarms(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        time TEXT NOT NULL,
        isActive INTEGER NOT NULL,
        repeatType INTEGER NOT NULL DEFAULT 0,
        customDays TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajouter les nouvelles colonnes pour la répétition
      await db.execute('ALTER TABLE alarms ADD COLUMN repeatType INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE alarms ADD COLUMN customDays TEXT NOT NULL DEFAULT \'\'');
    }
  }

  Future<int> insertAlarm(Alarm alarm) async {
    final db = await database;
    return await db.insert('alarms', alarm.toJson());
  }

  Future<List<Alarm>> getAllAlarms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'alarms',
      orderBy: 'time ASC',
    );

    return List.generate(maps.length, (i) {
      return Alarm.fromJson(maps[i]);
    });
  }

  Future<int> updateAlarm(Alarm alarm) async {
    final db = await database;
    return await db.update(
      'alarms',
      alarm.toJson(),
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
  }

  Future<int> deleteAlarm(int id) async {
    final db = await database;
    return await db.delete(
      'alarms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}