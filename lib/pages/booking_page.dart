import 'package:flutter/material.dart';
import '../core/session.dart';
import '../services/booking_service.dart';

class BookingPage extends StatefulWidget {
  final int carId;
  final double dailyPrice;

  const BookingPage({super.key, required this.carId, required this.dailyPrice});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? pickup, dropoff;

  final _locations = const [
    "Ramallah – City Center",
    "Ramallah – Al-Manara",
    "Ramallah – Company Branch",
    "Birzeit",
    "Other (Write address)",
  ];

  String pickupLoc = "";
  String dropoffLoc = "";

  bool pickupOther = false;
  bool dropoffOther = false;

  final _pickupOtherCtrl = TextEditingController();
  final _dropoffOtherCtrl = TextEditingController();

  double total = 0;

  final _service = BookingService();
  bool _sending = false;

  @override
  void dispose() {
    _pickupOtherCtrl.dispose();
    _dropoffOtherCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _calc() {
    if (pickup == null || dropoff == null) {
      setState(() => total = 0);
      return;
    }

    final diffHours = dropoff!.difference(pickup!).inHours;
    final days = (diffHours / 24).ceil();
    final safeDays = days <= 0 ? 1 : days;

    setState(() => total = safeDays * widget.dailyPrice);
  }

  Future<void> _pickDate({required bool isPickup}) async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (d == null) return;

    setState(() {
      final selected = DateTime(d.year, d.month, d.day, 0, 0);

      if (isPickup) {
        pickup = selected;
        if (dropoff != null && !dropoff!.isAfter(pickup!)) {
          dropoff = null;
        }
      } else {
        dropoff = selected;
      }

      _calc();
    });
  }

  Future<void> _submit() async {
    if (pickup == null || dropoff == null) {
      _toast("Please select pickup & drop-off dates");
      return;
    }
    if (!dropoff!.isAfter(pickup!)) {
      _toast("Drop-off must be after pickup");
      return;
    }

    final user = await Session.getUser();
    if (user == null) {
      _toast("Please login first");
      return;
    }

    final finalPickup = pickupOther ? _pickupOtherCtrl.text.trim() : pickupLoc.trim();
    final finalDropoff = dropoffOther ? _dropoffOtherCtrl.text.trim() : dropoffLoc.trim();

    if (finalPickup.isEmpty || finalDropoff.isEmpty) {
      _toast("Please select pickup & drop-off locations");
      return;
    }

    setState(() => _sending = true);

    try {
      final res = await _service.createBooking(
        carId: widget.carId,
        customerId: int.parse(user["user_id"].toString()),
        start: pickup!,
        end: dropoff!,
        pickupAddress: finalPickup,
        dropoffAddress: finalDropoff,
      );

      _toast("Booking created ✅ Total: \$${res["booking"]["total_price"]}");
      Navigator.pop(context);
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickupText = pickup == null ? "Select Pickup Date" : pickup.toString().substring(0, 10);
    final dropoffText = dropoff == null ? "Select Drop-off Date" : dropoff.toString().substring(0, 10);

    return Scaffold(
      appBar: AppBar(title: const Text("Booking")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(pickupText),
              trailing: const Icon(Icons.date_range),
              onTap: () => _pickDate(isPickup: true),
            ),
            ListTile(
              title: Text(dropoffText),
              trailing: const Icon(Icons.date_range),
              onTap: () => _pickDate(isPickup: false),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Pickup Location",
                border: OutlineInputBorder(),
              ),
              items: _locations.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) {
                setState(() {
                  pickupLoc = v ?? "";
                  pickupOther = pickupLoc.contains("Other");
                  if (!pickupOther) _pickupOtherCtrl.clear();
                });
              },
            ),
            if (pickupOther)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: _pickupOtherCtrl,
                  decoration: const InputDecoration(
                    labelText: "Enter pickup address",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Drop-off Location",
                border: OutlineInputBorder(),
              ),
              items: ["Same as pickup", ..._locations]
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  if (v == "Same as pickup") {
                    dropoffLoc = pickupLoc;
                    dropoffOther = pickupOther;
                    if (!dropoffOther) _dropoffOtherCtrl.clear();
                  } else {
                    dropoffLoc = v ?? "";
                    dropoffOther = dropoffLoc.contains("Other");
                    if (!dropoffOther) _dropoffOtherCtrl.clear();
                  }
                });
              },
            ),
            if (dropoffOther)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: _dropoffOtherCtrl,
                  decoration: const InputDecoration(
                    labelText: "Enter drop-off address",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            Text(
              "Total: \$${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Confirm Booking"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
