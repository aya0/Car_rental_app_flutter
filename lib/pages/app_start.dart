import 'package:flutter/material.dart';
import '../core/session.dart';
import 'login_page.dart';
import 'dashboards/customer_dashboard.dart';
import 'dashboards/employee_dashboard.dart';
import 'dashboards/manager_dashboard.dart';

class AppStart extends StatelessWidget {
  const AppStart({super.key});

  Future<Widget> _decideStart() async {
    final user = await Session.getUser();
    if (user == null) return const LoginPage();

    final role = user["role"]?.toString() ?? "";
    switch (role) {
      case "CUSTOMER":
        return const CustomerDashboard();
      case "WASHING_EMPLOYEE":
        return const EmployeeDashboard();
      case "COMPANY_MANAGER":
        return const ManagerDashboard();
      default:
        return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _decideStart(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snap.data!;
      },
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> feature/booking
