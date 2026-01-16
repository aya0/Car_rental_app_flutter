import 'package:flutter/material.dart';
import '../services/car_service.dart';
import '../core/api_config.dart';
import 'booking_page.dart';

class CarDetailsPage extends StatefulWidget {
  final int carId;
  const CarDetailsPage({super.key, required this.carId});

  @override
  State<CarDetailsPage> createState() => _CarDetailsPageState();
}

class _CarDetailsPageState extends State<CarDetailsPage> {
  final _service = CarService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchCarDetails(widget.carId);
  }

  Widget _placeholder({double w = 280, double h = 180}) {
    return Container(
      width: w,
      height: h,
      color: Colors.black12,
      child: const Center(child: Icon(Icons.image_not_supported, size: 40)),
    );
  }

  // ✅ يشتغل لو السيرفر رجّع url أو رجّع image_name
  String _resolveImageUrl(Map<String, dynamic> img) {
    final url = (img["url"] ?? "").toString().trim();
    if (url.isNotEmpty && (url.startsWith("http://") || url.startsWith("https://"))) {
      return url;
    }

    final name = (img["image_name"] ?? "").toString().trim();
    if (name.isEmpty) return "";

    return "${ApiConfig.carsImagesBase}/$name";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Car Details")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          if (!snap.hasData) {
            return const Center(child: Text("No data"));
          }

          final data = snap.data!;
          final car = Map<String, dynamic>.from(data["car"] ?? {});
          final images = (data["images"] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e))
              .toList();

          final double dailyPrice = double.tryParse(car["daily_price"].toString()) ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ صور السيارة (supports url or image_name)
                if (images.isNotEmpty)
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final imgUrl = _resolveImageUrl(images[i]);

                        if (imgUrl.isEmpty) return _placeholder();

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imgUrl,
                            width: 280,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          ),
                        );
                      },
                    ),
                  )
                else
                  _placeholder(w: double.infinity),

                const SizedBox(height: 12),

                Text(
                  "${car["brand"] ?? ""} ${car["model"] ?? ""} (${car["model_year"] ?? ""})",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "${car["type"] ?? ""} • ${car["transmission"] ?? ""} • ${car["fuel_type"] ?? ""} • Seats: ${car["seats"] ?? ""}",
                ),
                const SizedBox(height: 6),
                Text(
                  "Price: \$${car["daily_price"] ?? ""}/day",
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 14),
                const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                Text((car["description"] ?? "No description").toString()),

                const SizedBox(height: 14),
                const Text("Rental Terms", style: TextStyle(fontWeight: FontWeight.bold)),
                const Text(
                  "• ID required\n"
                  "• Return on time to avoid extra fees\n"
                  "• Fuel should be returned same level\n"
                  "• Damage fees apply if needed",
                ),

                const SizedBox(height: 18),

                // ✅ زر الحجز
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: dailyPrice <= 0
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingPage(
                                  carId: widget.carId,
                                  dailyPrice: dailyPrice,
                                ),
                              ),
                            );
                          },
                    child: const Text("Book this car"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
