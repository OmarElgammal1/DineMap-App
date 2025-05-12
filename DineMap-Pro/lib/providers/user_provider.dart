import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../utils/db.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    setError(null);

    try {
      // Initialize database and add test users if needed
      await _initializeDatabase();

      User? user = await DatabaseHelper.instance.login(email, password);

      if (user != null) {
        _currentUser = user;
        setLoading(false);
        return true;
      } else {
        setError('Invalid email or password.');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('Error: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    setLoading(true);
    setError(null);

    try {
      // Check if user already exists
      final existingUser = await DatabaseHelper.instance.login(email, password);

      if (existingUser != null) {
        setError('User already exists with this email');
        setLoading(false);
        return false;
      }

      // Create new user
      final newUser = User(
        name: name,
        email: email,
        password: password,
      );

      // Insert into database
      final userId = await DatabaseHelper.instance.insertUser(newUser);
      _currentUser = newUser;

      setLoading(false);
      return true;
    } catch (e) {
      setError('Failed to create account: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Initialize database with test users if needed
  Future<void> _initializeDatabase() async {
    try {
      final users = await DatabaseHelper.instance.getAllUsers();
      if (users.isEmpty) {
        await DatabaseHelper.instance.addTestUsers();
      }
    } catch (e) {
      print('Database initialization error: $e');
    }
  }
}