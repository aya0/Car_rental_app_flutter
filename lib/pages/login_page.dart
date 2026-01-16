import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../core/session.dart';
import 'dashboards/customer_dashboard.dart';
import 'dashboards/employee_dashboard.dart';
import 'dashboards/manager_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  bool _hidePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _goByRole(String role) {
    Widget page;
    switch (role) {
      case "CUSTOMER":
        page = const CustomerDashboard();
        break;
      case "WASHING_EMPLOYEE":
        page = const EmployeeDashboard();
        break;
      case "COMPANY_MANAGER":
        page = const ManagerDashboard();
        break;
      default:
        page = const CustomerDashboard();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      _toast("Fill email and password");
      return;
    }

    setState(() => _loading = true);

    try {
      final res = await _auth.login(email: email, password: pass);
      final user = Map<String, dynamic>.from(res["user"]);

      await Session.saveUser(user);

      _toast("Welcome ${user["full_name"]} ✅");
      _goByRole(user["role"].toString());
    } catch (e) {
      _toast(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: _hidePass,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_hidePass ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _hidePass = !_hidePass),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}