import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String role; // 'client' or 'lawyer'

  const DashboardScreen({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(role == 'client' ? 'Client Dashboard' : 'Lawyer Dashboard'),
      ),
      body: Center(
        child: Text('Welcome to the $role dashboard!'),
      ),
    );
  }
}
