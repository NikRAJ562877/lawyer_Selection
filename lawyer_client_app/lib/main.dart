import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import the JWT decoder
import 'providers/case_provider.dart'; // Adjust the path if necessary
import 'screens/login_screen.dart';
import 'screens/client_dashboard.dart';
import 'screens/lawyer_dashboard.dart'; // Make sure this is implemented

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CaseProvider(), // Provide the CaseProvider
      child: MaterialApp(
        title: 'Lawyer Client App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
          future: getInitialScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return snapshot.data as Widget; // Return the appropriate screen
            }
          },
        ),
        routes: {
          '/clientDashboard': (context) => ClientDashboard(),
          '/lawyerDashboard': (context) => LawyerDashboard(),
          '/login': (context) => LoginScreen(),
        },
      ),
    );
  }

  Future<Widget> getInitialScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? role = prefs.getString('role'); // Get the saved role

    // Debugging prints
    print('Token: $token');
    print('Role: $role');

    if (token != null && !JwtDecoder.isExpired(token)) {
      if (role == 'client') {
        return ClientDashboard(); // Navigate to Client Dashboard
      } else if (role == 'lawyer') {
        return LawyerDashboard(); // Navigate to Lawyer Dashboard
      }
    }
    return LoginScreen(); // Navigate to Login Screen if no token or expired
  }
}
