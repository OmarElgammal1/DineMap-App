import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  static bool _initialized = false;

  DatabaseHelper._internal();

  // Simplify initialization
  static Future<void> initialize() async {
    if (!_initialized) {
      _initialized = true;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
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
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        profile_pic TEXT
      )
    ''');
  }

  // Create new user
  Future<int> insertUser(User user) async {
    await initialize();
    Database db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    await initialize();
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Get single user by ID
  Future<User?> getUserById(int id) async {
    await initialize();
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
    await initialize();
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
    await initialize();
    Database db = await instance.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Login method (supports login with email)
  Future<User?> login(String email, String password) async {
    await initialize();
    Database db = await instance.database;

    // Try with email
    List<Map<String, dynamic>> resultByEmail = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    return resultByEmail.isNotEmpty ? User.fromMap(resultByEmail.first) : null;
  }

  // Add some test users
  Future<void> addTestUsers() async {
    await initialize();
    try {
      await insertUser(User(
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
      ));

      await insertUser(User(
        name: 'Jane Smith',
        email: 'jane@example.com',
        password: 'password456',
      ));

      print('Test users added successfully');
    } catch (e) {
      print('Error adding test users: $e');
    }
  }
}