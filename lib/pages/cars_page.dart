
import 'package:flutter/material.dart';
import '../services/car_service.dart';

class CarsPage extends StatefulWidget {
  const CarsPage({super.key});

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {
  final _service = CarService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchAvailableCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Cars")),
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