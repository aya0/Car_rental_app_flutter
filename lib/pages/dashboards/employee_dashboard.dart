
import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../login_page.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  Future<void> _logout(BuildContext context) async {
    await Session.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Washing Employee Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: const Center(
        child: Text("Here: view bookings, update car status, etc."),
      ),
    );
  }
}