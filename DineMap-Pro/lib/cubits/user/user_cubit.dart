import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/db.dart';
import '../../models/user.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  // Login user
  Future<bool> login(String email, String password) async {
    emit(UserLoading());

    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        emit(UserError('Email and password cannot be empty'));
        return false;
      }

      // Attempt login
      User? user = await DatabaseHelper.instance.login(email, password);

      if (user != null) {
        emit(UserAuthenticated(user));
        return true;
      } else {
        emit(UserError('Invalid email or password'));
        return false;
      }
    } catch (e) {
      emit(UserError('Login failed: $e'));
      return false;
    }
  }

  // Sign up user
  Future<bool> signup(String name, String email, String password) async {
    emit(UserLoading());

    try {
      // Validate inputs
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        emit(UserError('All fields are required'));
        return false;
      }

      // Create user object
      User newUser = User(
        name: name,
        email: email,
        password: password,
      );

      // Save to database
      int userId = await DatabaseHelper.instance.insertUser(newUser);
      if (userId > 0) {
        // Set ID and emit authenticated state
        newUser.id = userId;
        emit(UserAuthenticated(newUser));
        return true;
      } else {
        emit(UserError('Failed to create account'));
        return false;
      }
    } catch (e) {
      emit(UserError('Registration failed: $e'));
      return false;
    }
  }

  // Logout user
  void logout() {
    emit(UserInitial());
  }

  // Get error message
  String? get errorMessage {
    if (state is UserError) {
      return (state as UserError).message;
    }
    return null;
  }

  // Check if loading
  bool get isLoading {
    return state is UserLoading;
  }

  // Get current user
  User? get currentUser {
    if (state is UserAuthenticated) {
      return (state as UserAuthenticated).user;
    }
    return null;
  }
}