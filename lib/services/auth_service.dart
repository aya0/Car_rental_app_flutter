import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class AuthService {
<<<<<<< HEAD
 
=======
  /// =========================
  /// Register (Sign Up)
  /// =========================
>>>>>>> feature/booking
  Future<Map<String, dynamic>> registerCustomer({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/auth_register.php");

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "full_name": fullName,
        "phone": phone,
        "email": email,
        "password": password,
        "role": role, // CUSTOMER | WASHING_EMPLOYEE | COMPANY_MANAGER
      }),
    );

    // Decode response safely
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception("Invalid server response");
    }

    // Handle HTTP errors
    if (response.statusCode >= 400) {
      throw Exception(decoded["message"] ?? "Registration failed");
    }

    // Handle logical errors
    if (decoded["ok"] != true) {
      throw Exception(decoded["message"] ?? "Registration failed");
    }

    return decoded;
  }

  /// =========================
  /// Login (NEXT STEP)
  /// =========================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/auth_login.php");

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception("Invalid server response");
    }

    if (response.statusCode >= 400) {
      throw Exception(decoded["message"] ?? "Login failed");
    }

    if (decoded["ok"] != true) {
      throw Exception(decoded["message"] ?? "Login failed");
    }

    return decoded;
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> feature/booking
