import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'user.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI database for non-mobile platforms
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), 'shop_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender TEXT NOT NULL,
        student_id TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        level INTEGER NOT NULL,
        password TEXT NOT NULL,
        profile_pic TEXT
      )
    ''');
  }

  // Create new user
  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Get single user by ID
  Future<User?> getUserById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  // Update user (except ID)
  Future<int> updateUser(User user) async {
    Database db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete user
  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Flexible login method (supports login with either studentId or email)
  Future<User?> login(String identifier, String password) async {
    Database db = await instance.database;

    // Try to login with studentId
    List<Map<String, dynamic>> resultById = await db.query(
      'users',
      where: 'student_id = ? AND password = ?',
      whereArgs: [identifier, password],
    );

    if (resultById.isNotEmpty) {
      return User.fromMap(resultById.first);
    }

    // If not found, try with email
    List<Map<String, dynamic>> resultByEmail = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [identifier, password],
    );

    return resultByEmail.isNotEmpty ? User.fromMap(resultByEmail.first) : null;
  }

  // Add some test users
  Future<void> addTestUsers() async {
    try {
      await insertUser(User(
        name: 'John Doe',
        gender: 'Male',
        studentId: 'user1',
        email: 'john@example.com',
        level: 3,
        password: 'password123',
      ));

      await insertUser(User(
        name: 'Jane Smith',
        gender: 'Female',
        studentId: 'user2',
        email: 'jane@example.com',
        level: 4,
        password: 'password456',
      ));

      print('Test users added successfully');
    } catch (e) {
      print('Error adding test users: $e');
    }
  }
}