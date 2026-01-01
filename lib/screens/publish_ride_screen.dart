import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/ride_service.dart';
import '../widgets/back_button.dart';

class PublishRideScreen extends StatefulWidget {
  const PublishRideScreen({super.key});

  @override
  State<PublishRideScreen> createState() => _PublishRideScreenState();
}

class _PublishRideScreenState extends State<PublishRideScreen> {
  final TextEditingController _from = TextEditingController();
  final TextEditingController _to = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _seats = TextEditingController(text: '2');
  DateTime? _departureTime;
  bool _womenOnly = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _price.dispose();
    _seats.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _departureTime ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_departureTime ?? now.add(const Duration(hours: 2))),
    );
    if (time == null) return;

    setState(() {
      _departureTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _publish() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      context.go('/welcome');
      return;
    }

    final from = _from.text.trim();
    final to = _to.text.trim();
    final price = double.tryParse(_price.text.trim());
    final seats = int.tryParse(_seats.text.trim());

    if (from.isEmpty || to.isEmpty) {
      setState(() => _error = 'Veuillez entrer la wilaya de départ et d\'arrivée.');
      return;
    }
    if (price == null || price <= 0) {
      setState(() => _error = 'Veuillez entrer un prix valide.');
      return;
    }
    if (seats == null || seats <= 0) {
      setState(() => _error = 'Veuillez entrer un nombre de places valide.');
      return;
    }
    if (_departureTime == null) {
      setState(() => _error = 'Veuillez choisir la date/heure de départ.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await RideService().createRide(
        driverId: user.uid,
        driverName: (user.email ?? 'Chauffeur'),
        from: from,
        to: to,
        priceTnd: price,
        seatsAvailable: seats,
        womenOnly: _womenOnly,
        departureTime: _departureTime!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trajet publié.')),
      );
      context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dt = _departureTime;
    final dtLabel = dt == null
        ? 'Choisir date & heure'
        : '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBarWithBack(
        title: 'Publier un trajet',
        fallbackRoute: '/home', // Retour à l'accueil
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _from,
                    decoration: const InputDecoration(
                      labelText: 'Wilaya de départ',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _to,
                    decoration: const InputDecoration(
                      labelText: "Wilaya d'arrivée",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _price,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Prix (TND)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _seats,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Places',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.event_seat_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _pickDateTime,
                    icon: const Icon(Icons.schedule),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(dtLabel),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _womenOnly,
                    onChanged: _loading ? null : (v) => setState(() => _womenOnly = v),
                    title: const Text('Femmes uniquement'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _publish,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(_loading ? 'Publication...' : 'Publier'),
            ),
          ),
        ],
      ),
    );
  }
}
