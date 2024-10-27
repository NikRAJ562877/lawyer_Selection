import 'package:flutter/material.dart';
import 'select_case_screen.dart'; // Import the new screen
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; // Ensure you import the LoginScreen for logout

class ClientDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Client Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context), // Add logout functionality
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Client Dashboard'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Select Case Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelectCaseScreen()),
                );
              },
              child: const Text(
                  'Next'), // This button will take the user to the next screen
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Clear the token
    await prefs.remove('role'); // Clear the role if needed

    // Navigate back to the Login Screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => LoginScreen()), // Ensure you import LoginScreen
      (Route<dynamic> route) => false,
    );
  }
}
