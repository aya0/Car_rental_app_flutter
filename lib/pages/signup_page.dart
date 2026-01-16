import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = AuthService();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  String _selectedRole = 'CUSTOMER';

  bool _loading = false;
  bool _hidePass = true;

  final List<String> _roles = [
    'CUSTOMER',
    'WASHING_EMPLOYEE',
    'COMPANY_MANAGER',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if ([name, phone, email, pass, confirm].any((e) => e.isEmpty)) {
      _toast("Please fill all fields");
      return;
    }

    if (!email.contains("@")) {
      _toast("Invalid email");
      return;
    }

    if (pass.length < 6) {
      _toast("Password must be at least 6 characters");
      return;
    }

    if (pass != confirm) {
      _toast("Passwords do not match");
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.registerCustomer(
        fullName: name,
        phone: phone,
        email: email,
        password: pass,
        role: _selectedRole,
      );

      _toast("Account created successfully ✅");

      // ✅ يرجع لصفحة اللوج إن (لأنك جاي منها)
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _toast(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field(_nameCtrl, "Full Name"),
            _field(_phoneCtrl, "Phone", TextInputType.phone),
            _field(_emailCtrl, "Email", TextInputType.emailAddress),

            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: _roles
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRole = v!),
              decoration: const InputDecoration(
                labelText: "Role",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            _passwordField(_passCtrl, "Password"),
            _passwordField(_confirmPassCtrl, "Confirm Password"),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _signup,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Create Account"),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ (اختياري) لينك يرجع للوج إن
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      [TextInputType type = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _passwordField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: _hidePass,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(_hidePass ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _hidePass = !_hidePass),
          ),
        ),
      ),
    );
  }
}

