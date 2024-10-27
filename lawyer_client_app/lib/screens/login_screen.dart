import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lawyer_client_app/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'client_dashboard.dart';
import 'lawyer_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final String _role = 'client'; // Default role
  bool _isLoading = false; // For loading state
  String _errorMessage = ''; // For error messages

  Future<void> login() async {
    setState(() {
      _isLoading = true; // Set loading state
      _errorMessage = ''; // Reset error message
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:5000/api/auth/login'), // Ensure the URI is correct
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': _role, // Sending the role from the dropdown
        }),
      );

      print('Response status: ${response.statusCode}'); // Log status code
      print('Response body: ${response.body}'); // Log response body

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']); // Store JWT
        await prefs.setString('role', data['role']); // Store role

        // Navigate to the respective dashboard based on the role
        if (data['role'] == 'client') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ClientDashboard()),
          );
        } else if (data['role'] == 'lawyer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LawyerDashboard()),
          );
        }
      } else {
        // Handle error
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage =
              errorData['message'] ?? 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
      print('Error: $e'); // Log any exceptions
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed:
                  _isLoading ? null : login, // Disable button while loading
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'), // Show loading indicator
            ),
            if (_errorMessage.isNotEmpty) // Show error message
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
