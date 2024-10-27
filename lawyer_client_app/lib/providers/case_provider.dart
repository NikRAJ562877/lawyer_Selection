// lib/providers/case_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Ensure you have this import
import 'package:shared_preferences/shared_preferences.dart';
import '../models/case_model.dart';

class CaseProvider with ChangeNotifier {
  String _status = '';
  List<Case> _cases = []; // Store the list of cases
  bool _hasError = false;

  String get status => _status;
  List<Case> get cases => _cases; // Getter for the cases list
  bool get hasError => _hasError;

  Future<void> submitCase(Case newCase) async {
    _hasError = false;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/cases'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(newCase.toJson()),
      );

      if (response.statusCode == 201) {
        _status = 'Case submitted successfully!';
        await fetchCases(); // Fetch updated cases
      } else {
        _status = 'Failed to submit case: ${response.body}';
      }
    } catch (error) {
      _hasError = true;
      _status = 'Error: $error';
    }
    notifyListeners();
  }

  Future<void> fetchCases() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:5000/api/cases'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        _cases =
            jsonResponse.map((caseJson) => Case.fromJson(caseJson)).toList();
      } else {
        _hasError = true; // Handle error if fetching fails
        _status = 'Failed to load cases: ${response.body}';
      }
    } catch (error) {
      _hasError = true; // Handle error if fetching fails
      _status = 'Error fetching cases: $error';
    }
    notifyListeners(); // Notify listeners after updating cases
  }
}
