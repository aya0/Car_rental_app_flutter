import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class CarService {
  Future<List<Map<String, dynamic>>> fetchAvailableCars() async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/cars_list.php");

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Server error: ${res.statusCode}");
    }

    final decoded = jsonDecode(res.body);
    if (decoded["ok"] != true) {
      throw Exception(decoded["message"] ?? "Unknown error");
    }

    final data = (decoded["data"] as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return data;
  }
}