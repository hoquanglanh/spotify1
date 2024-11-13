import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spotify/screens/sign_in.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  String? _fullName;
  String? _email;
  // ignore: unused_field
  String? _password;
  bool _obscurePassword = true;

  final storage = FlutterSecureStorage();

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Za-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<bool> isEmailRegistered(String email) async {
    String? usersJson = await storage.read(key: 'registered_users');
    if (usersJson != null) {
      List<dynamic> users = jsonDecode(usersJson);
      return users.any((user) => user['email'] == email);
    }
    return false;
  }

  Future<void> saveNewUser(String fullName, String email, String password) async {
  String? usersJson = await storage.read(key: 'registered_users');
  List<dynamic> users = [];
  if (usersJson != null) {
    users = jsonDecode(usersJson);
  }
  
  // Store full_name, email, and password securely
  users.add({'full_name': fullName, 'email': email, 'password': password});
  
  await storage.write(key: 'registered_users', value: jsonEncode(users));
}


  Future<void> _register() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    try {
      bool emailExists = await isEmailRegistered(_email!);
      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email này đã được đăng ký')),
        );
        return;
      }

      // Save full name, email, and password
      await saveNewUser(_fullName!, _email!, _password!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thành công')),
      );

      // Navigate to SignInScreen after successful registration
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SignInScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 34, 34),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/spo.png',
                      width: 200,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Register',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      text: 'If You Need Any Support ',
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: 'Click Here',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    hintText: 'Full Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                    onSaved: (value) => _fullName = value,
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                    hintText: 'Enter Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        if (value.isNotEmpty && !isValidEmail(value)) {
                          _emailError = 'Please enter a valid email';
                        } else {
                          _emailError = null;
                        }
                      });
                    },
                    onSaved: (value) => _email = value,
                    errorText: _emailError,
                  ),
                  SizedBox(height: 10),
                  _buildTextField(
                    hintText: 'Password',
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (!isValidPassword(value)) {
                        return 'Password must be at least 8 characters long and contain both letters and numbers';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF42C83C),
                      padding: EdgeInsets.symmetric(vertical: 20),
                      minimumSize: Size(200, 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _register,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Or', style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(child: Divider(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/google.png', height: 40),
                      SizedBox(width: 20),
                      Image.asset('assets/images/apple.png', height: 40),
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Do You Have An Account? ', style: TextStyle(color: Colors.white)),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SignInScreen()));
                        },
                        child: Text('Sign In', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    void Function(String)? onChanged,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      obscureText: obscureText,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        filled: true,
        fillColor: const Color.fromARGB(255, 34, 34, 34),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: const Color.fromARGB(255, 82, 82, 82), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255), width: 2),
        ),
        suffixIcon: suffixIcon,
        errorText: errorText,
        errorStyle: TextStyle(color: Colors.red),
      ),
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
    );
  }
}