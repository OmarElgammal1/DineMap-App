import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user.dart'; // Keep if you parse response into User model
import 'user_state.dart';
import '../../config/constants.dart'; // Your API base URL

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  Future<bool> login(String email, String password) async {
    emit(UserLoading());
    try {
      if (email.isEmpty || password.isEmpty) {
        emit(UserError('Email and password cannot be empty'));
        return false;
      }

      final response = await http.post(
        Uri.parse('$API_BASE_URL/login'), // Use your constant
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {

        emit(UserAuthenticated(User(id: jsonDecode(response.body)['id'], name: jsonDecode(response.body)['name'], email: email, password: ''))); // Adjust User model as needed
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        emit(UserError(errorData['message'] ?? 'Invalid email or password'));
        return false;
      }
    } catch (e) {
      emit(UserError('Login failed: $e'));
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password, String confirmPassword, {String? gender, int? level}) async { // Added confirmPassword and optional fields
    emit(UserLoading());
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) { // Added confirmPassword check
        emit(UserError('All fields are required'));
        return false;
      }
      if (password != confirmPassword) {
        emit(UserError('Passwords do not match'));
        return false;
      }

      final response = await http.post(
        Uri.parse('$API_BASE_URL/signup'), // Use your constant
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{ // Use dynamic for mixed types
          'name': name,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
          if (gender != null) 'gender': gender, // Add optional fields if provided
          if (level != null) 'level': level,
        }),
      );

      if (response.statusCode == 201) { // Flask returns 201 for successful creation
        // final responseData = jsonDecode(response.body);
        // You might want to log the user in directly or navigate to login
        emit(UserAuthenticated(User(id:jsonDecode(response.body)['id'], name: name, email: email, password: ''))); // Adjust as needed
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        emit(UserError(errorData['message'] ?? 'Failed to create account'));
        return false;
      }
    } catch (e) {
      emit(UserError('Registration failed: $e'));
      return false;
    }
  }

  // Logout user (remains the same if it just clears local state)
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