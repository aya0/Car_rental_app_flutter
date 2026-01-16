<<<<<<< HEAD

import 'package:flutter/material.dart';
import '../services/car_service.dart';
=======
import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/car_service.dart';
import 'car_details_page.dart';
>>>>>>> feature/booking

class CarsPage extends StatefulWidget {
  const CarsPage({super.key});

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {
  final _service = CarService();
<<<<<<< HEAD
  late Future<List<Map<String, dynamic>>> _future;
=======
  final _searchCtrl = TextEditingController();

  final _types = const ["ALL", "SUV", "SEDAN", "HATCHBACK", "VAN", "PICKUP", "LUXURY"];
  String _selectedType = "ALL";

  RangeValues _priceRange = const RangeValues(0, 200);
  bool _loading = false;
  List<Car> _cars = [];
>>>>>>> feature/booking

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _future = _service.fetchAvailableCars();
=======
    _loadCars();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCars() async {
    setState(() => _loading = true);
    try {
      final cars = await _service.fetchCars(
        type: _selectedType,
        query: _searchCtrl.text,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
      );
      setState(() => _cars = cars);
    } catch (e) {
      _toast(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
>>>>>>> feature/booking
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Cars")),
<<<<<<< HEAD
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final cars = snapshot.data ?? [];
          if (cars.isEmpty) {
            return const Center(child: Text("No cars available"));
          }

          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, i) {
              final c = cars[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text("${c['brand']} ${c['model']} (${c['model_year']})"),
                  subtitle: Text("${c['type']} • ${c['transmission']} • \$${c['daily_price']}/day"),
                  trailing: Text(c['status']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
=======
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        items: _types
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _selectedType = v!);
                          _loadCars();
                        },
                        decoration: const InputDecoration(
                          labelText: "Type",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: _loadCars,
                      icon: const Icon(Icons.refresh),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    labelText: "Search brand/model",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _loadCars,
                    ),
                  ),
                  onSubmitted: (_) => _loadCars(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Price Range"),
                    const SizedBox(width: 10),
                    Text(
                      "\$${_priceRange.start.toStringAsFixed(0)} - \$${_priceRange.end.toStringAsFixed(0)}",
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 200,
                  divisions: 20,
                  labels: RangeLabels(
                    _priceRange.start.toStringAsFixed(0),
                    _priceRange.end.toStringAsFixed(0),
                  ),
                  onChanged: (v) => setState(() => _priceRange = v),
                  onChangeEnd: (_) => _loadCars(),
                ),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _cars.isEmpty
                    ? const Center(child: Text("No cars found"))
                    : ListView.builder(
                        itemCount: _cars.length,
                        itemBuilder: (context, i) {
                          final c = _cars[i];

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  c.coverUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image_not_supported),
                                ),
                              ),
                              title: Text("${c.brand} ${c.model} (${c.year})"),
                              subtitle: Text(
                                "${c.type} • ${c.transmission} • \$${c.dailyPrice}/day",
                              ),
                              trailing: Text(c.status),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CarDetailsPage(carId: c.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
>>>>>>> feature/booking
