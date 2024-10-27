import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class LawyerDashboard extends StatefulWidget {
  @override
  _LawyerDashboardState createState() => _LawyerDashboardState();
}

class _LawyerDashboardState extends State<LawyerDashboard> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String selectedCaseType = 'Type A'; // Example default case type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lawyer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context), // Logout functionality
          ),
        ],
      ),
      body: Column(
        children: [
          // Form to submit a case
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Case Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Case Description'),
                ),
                // Dropdown for case type
                DropdownButton<String>(
                  value: selectedCaseType,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCaseType = newValue!;
                    });
                  },
                  items: <String>[
                    'Type A',
                    'Type B',
                    'Type C',
                    'Type D',
                    'Type E'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: () => _submitCase(context), // Call submit function
                  child: const Text('Submit Case'),
                ),
              ],
            ),
          ),
          // FutureBuilder to display cases
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchCases(), // Method to fetch cases
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final cases = snapshot.data!;
                return ListView.builder(
                  itemCount: cases.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(cases[index]['title']),
                      subtitle: Text(cases[index]['description']),
                      trailing: ElevatedButton(
                        onPressed: () {
                          lockCase(
                              context, cases[index]['_id']); // Lock the case
                        },
                        child: const Text('Lock Case'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCase(BuildContext context) async {
    final caseData = {
      'title': titleController.text,
      'description': descriptionController.text,
      'caseType': selectedCaseType,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/cases'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(caseData),
      );

      if (response.statusCode == 201) {
        titleController.clear();
        descriptionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case submitted successfully!')),
        );
      } else {
        print('Failed to submit case: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit case: ${response.body}')),
        );
      }
    } catch (error) {
      print('Error submitting case: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  Future<List<dynamic>> fetchCases() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://localhost:5000/api/cases'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load cases');
    }
  }

  Future<void> lockCase(BuildContext context, String caseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Uncomment and use userId if you plan to include it in the request
    // final userId = prefs.getString('userId');

    final response = await http.post(
      Uri.parse('http://localhost:5000/api/cases/lock'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'caseId': caseId,
        // Uncomment and use userId if you need to pass it in the future
        // 'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Case locked successfully!')),
      );
    } else {
      print('Failed to lock case: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to lock case: ${response.body}')),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Clear the token
    await prefs.remove('userId'); // Clear the user ID if needed
    await prefs.remove('role'); // Clear the role if needed

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => LoginScreen()), // Navigate to Login Screen
      (Route<dynamic> route) => false,
    );
  }
}
