import '../../models/user.dart';

abstract class UserState {}

// Initial state
class UserInitial extends UserState {}

// Loading state
class UserLoading extends UserState {}

// Authenticated state with user data
class UserAuthenticated extends UserState {
  final User user;

  UserAuthenticated(this.user);
}

// Error state
class UserError extends UserState {
  final String message;

  UserError(this.message);
}