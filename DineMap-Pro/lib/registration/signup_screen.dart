import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/user/user_cubit.dart';
import '../cubits/user/user_state.dart';
import '../home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _gender; // Remains nullable as it's optional
  int? _level;    // Remains nullable as it's optional
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final Color _themeColor = const Color(0xFFFF7043);
  final Color _prefixIconColor = const Color(0xFFFF7043);
  final Color _logoIconColor = const Color(0xFFFD6A3C);
  final Color _logoBackgroundColor = const Color(0xFFFBE9E7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserAuthenticated) {
            final userId = state.user.id;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(userId: userId)),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: _logoBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.restaurant,
                          size: 60,
                          color: _logoIconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Restaurant Finder',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _themeColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Create your account to get started',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 50),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(Icons.person, color: _prefixIconColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Gender field (Optional - no validator for being null)
                    FormField<String>(
                      // REMOVED: validator that checks if _gender is null
                      builder: (FormFieldState<String> fieldState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0, bottom: 8.0, top: 8.0),
                              child: Text(
                                'Gender (Optional)', // Indicate it's optional in the label
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                // No error border needed if it's optional
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'Male',
                                    groupValue: _gender,
                                    onChanged: (value) {
                                      setState(() => _gender = value);
                                      fieldState.didChange(value);
                                    },
                                    activeColor: _themeColor,
                                  ),
                                  const Text('Male'),
                                  const SizedBox(width: 20),
                                  Radio<String>(
                                    value: 'Female',
                                    groupValue: _gender,
                                    onChanged: (value) {
                                      setState(() => _gender = value);
                                      fieldState.didChange(value);
                                    },
                                    activeColor: _themeColor,
                                  ),
                                  const Text('Female'),
                                ],
                              ),
                            ),
                            // No error text display needed for being unselected
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'e.g., name@stud.fci-cu.edu.eg',
                        prefixIcon: Icon(Icons.email, color: _prefixIconColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
                        if (!emailRegex.hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        if (!value.endsWith('@stud.fci-cu.edu.eg')) {
                          return 'Email must end with @stud.fci-cu.edu.eg';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Level field (Optional - no validator for being null)
                    DropdownButtonFormField<int>(
                      value: _level,
                      decoration: InputDecoration(
                        labelText: 'Level (Optional)', // Indicate it's optional
                        hintText: 'Select your level (Optional)',
                        prefixIcon: Icon(Icons.school, color: _prefixIconColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                      ),
                      items: [1, 2, 3, 4]
                          .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text('Level $level'),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => _level = value),
                      // REMOVED: validator that checks if value is null
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock, color: _prefixIconColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        if (value.length < 8) return 'At least 8 characters required';
                        return null;
                      },
                      onChanged: (value) {
                        if (_confirmPasswordController.text.isNotEmpty) {
                          _formKey.currentState?.validate();
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your password',
                        prefixIcon: Icon(Icons.lock_outline, color: _prefixIconColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Confirm password is required';
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: state is UserLoading
                          ? Center(child: CircularProgressIndicator(color: _themeColor))
                          : ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _themeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (state is UserError)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: _themeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) { // This will still validate required fields
      final name = _nameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      context.read<UserCubit>().signup(
        name,
        email,
        password,
        confirmPassword,
        gender: _gender, // Will be null if not selected
        level: _level,   // Will be null if not selected
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}