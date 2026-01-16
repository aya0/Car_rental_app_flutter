import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class BookingService {
  Future<Map<String, dynamic>> createBooking({
    required int carId,
    required int customerId,
    required DateTime start,
    required DateTime end,
    required String pickupAddress,
    required String dropoffAddress,
    double deliveryFee = 0,
    double discountAmount = 0,
    double addonsTotal = 0,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/car_booking.php");

    final body = {
      "car_id": carId,
      "customer_id": customerId,
      "start_datetime": start.toString().substring(0, 19),
      "end_datetime": end.toString().substring(0, 19),
      "pickup_address": pickupAddress,
      "dropoff_address": dropoffAddress,
      "delivery_fee": deliveryFee,
      "discount_amount": discountAmount,
      "addons_total": addonsTotal,
    };

    try {
      final res = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 12));

      Map<String, dynamic> json;
      try {
        json = jsonDecode(res.body);
      } catch (_) {
        throw Exception("Server response is not JSON:\n${res.body}");
      }

      if (res.statusCode != 200 || json["ok"] != true) {
        throw Exception(json["message"] ?? "Booking failed");
      }

      return json;
    } catch (e) {
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }
}
