// services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/case_model.dart'; // Import the case model

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  // Login API method
  static Future<void> login(String email, String password) async {
    print('debug password failed: $password');
    print('debug email failed: $email');
    final response = await http.post(
      // Uri.parse('$baseUrl/auth/login'),
      Uri.parse('http://localhost:5000/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    // Log the response status code and body
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString(
          'userId', data['userId']); // Store user ID if needed
      await prefs.setString('role', data['role']); // Store role
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // API method for submitting a case
  static Future<void> submitCase(Case caseData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found. Please log in again.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/cases'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Include token for authorization
      },
      body: jsonEncode(<String, String>{
        'title': caseData.title,
        'description': caseData.description,
        'caseType': caseData.caseType,
      }),
    );

    // Print the response for debugging purposes
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to submit case: ${response.body}');
    }
  }

  //registration
  Future<void> registerUser(String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'role': role}),
    );

    if (response.statusCode == 201) {
      print('Registration successful');
    } else {
      print('Registration failed: ${response.body}');
    }
  }

  // API method for retrieving cases
  static Future<List<Case>> getCases() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/cases'),
      headers: <String, String>{
        'Authorization': 'Bearer $token', // Include token for authorization
      },
    );

    if (response.statusCode == 200) {
      // Assuming the response body is a JSON array of cases
      List<dynamic> data = jsonDecode(response.body);
      return data
          .map((caseJson) => Case.fromJson(caseJson))
          .toList(); // Convert JSON to Case objects
    } else {
      throw Exception('Failed to fetch cases: ${response.body}');
    }
  }
}

// Retrieve token and role from SharedPreferences
Future<Map<String, String?>> getAuthTokenAndRole() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? role = prefs.getString('role');

  // Debugging logs to verify the values are being retrieved
  print('Token from SharedPreferences: $token');
  print('Role from SharedPreferences: $role');

  return {'token': token, 'role': role};
}
