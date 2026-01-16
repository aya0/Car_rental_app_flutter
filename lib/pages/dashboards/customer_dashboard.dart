import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../cars_page.dart';
import '../login_page.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

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
        title: const Text("Customer Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CarsPage()));
          },
          child: const Text("Browse Cars"),
        ),
      ),
    );
  }
}