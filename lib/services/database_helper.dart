import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/local/local_note.dart';
import '../models/local/local_reminder.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ai_notes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create notes table
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_reminder INTEGER NOT NULL DEFAULT 0,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        pending_action TEXT
      )
    ''');

    // Create reminders table
    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        time TEXT NOT NULL,
        date TEXT NOT NULL,
        runtime TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        priority TEXT NOT NULL DEFAULT 'medium',
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        pending_action TEXT
      )
    ''');
  }

  // Notes operations
  Future<int> insertNote(LocalNote note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<LocalNote>> getAllNotes({bool includeDeleted = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: includeDeleted ? null : 'is_deleted = ?',
      whereArgs: includeDeleted ? null : [0],
      orderBy: 'is_pinned DESC, created_at DESC',
    );
    return List.generate(maps.length, (i) => LocalNote.fromMap(maps[i]));
  }

  Future<LocalNote?> getNoteById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'server_id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return LocalNote.fromMap(maps.first);
    }
    return null;
  }

  Future<LocalNote?> getNoteByServerId(String serverId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'server_id = ?',
      whereArgs: [serverId],
    );
    if (maps.isNotEmpty) {
      return LocalNote.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateNote(LocalNote note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.update(
      'notes',
      {'is_deleted': 1, 'pending_action': 'delete', 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> permanentlyDeleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LocalNote>> getUnsyncedNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => LocalNote.fromMap(maps[i]));
  }

  // Reminders operations
  Future<int> insertReminder(LocalReminder reminder) async {
    final db = await database;
    return await db.insert('reminders', reminder.toMap());
  }

  Future<List<LocalReminder>> getAllReminders({bool includeDeleted = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      where: includeDeleted ? null : 'is_deleted = ?',
      whereArgs: includeDeleted ? null : [0],
      orderBy: 'date ASC, time ASC',
    );
    return List.generate(maps.length, (i) => LocalReminder.fromMap(maps[i]));
  }

  Future<LocalReminder?> getReminderById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      where: 'server_id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return LocalReminder.fromMap(maps.first);
    }
    return null;
  }

  Future<LocalReminder?> getReminderByServerId(String serverId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      where: 'server_id = ?',
      whereArgs: [serverId],
    );
    if (maps.isNotEmpty) {
      return LocalReminder.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateReminder(LocalReminder reminder) async {
    final db = await database;
    return await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.update(
      'reminders',
      {'is_deleted': 1, 'pending_action': 'delete', 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> permanentlyDeleteReminder(int id) async {
    final db = await database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LocalReminder>> getUnsyncedReminders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminders',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => LocalReminder.fromMap(maps[i]));
  }

  // Utility methods
  Future<void> markNoteSynced(int id, String? serverId) async {
    final db = await database;
    await db.update(
      'notes',
      {
        'is_synced': 1,
        'server_id': serverId,
        'pending_action': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markReminderSynced(int id, String? serverId) async {
    final db = await database;
    await db.update(
      'reminders',
      {
        'is_synced': 1,
        'server_id': serverId,
        'pending_action': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearSyncedDeletedItems() async {
    final db = await database;
    await db.delete('notes', where: 'is_deleted = 1 AND is_synced = 1');
    await db.delete('reminders', where: 'is_deleted = 1 AND is_synced = 1');
  }
  
  // Truncate database after successful sync
  Future<void> truncateDatabase() async {
    final db = await database;
    await db.delete('notes');
    await db.delete('reminders');
    debugPrint('Database truncated after successful sync');
  }
  
  // Clear only synced items (keep unsynced local changes)
  Future<void> clearSyncedItems() async {
    final db = await database;
    await db.delete('notes', where: 'is_synced = 1');
    await db.delete('reminders', where: 'is_synced = 1');
    debugPrint('Synced items cleared from database');
  }
  
  // Check if there are any unsynced items
  Future<bool> hasUnsyncedData() async {
    final db = await database;
    final notesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM notes WHERE is_synced = 0')
    ) ?? 0;
    final remindersCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM reminders WHERE is_synced = 0')
    ) ?? 0;
    return notesCount > 0 || remindersCount > 0;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}