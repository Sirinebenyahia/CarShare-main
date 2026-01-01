import 'package:flutter/material.dart';

class SearchResultsScreen extends StatelessWidget {
  final String from;
  final String to;

  const SearchResultsScreen({super.key, this.from = '', this.to = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // --- SECTION HAUTE : RECHERCHE ET FILTRES ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rechercher un trajet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "D'où partez-vous ?",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF6F7FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterButton(Icons.tune, "Filtres", isSelected: true),
                        _buildFilterButton(null, "Prix"),
                        _buildFilterButton(null, "Places"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- SECTION BASSE : LISTE DES TRAJETS ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Trajets disponibles', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('5 résultats', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: const [
                          _RideCard(
                            name: "Salma Béji",
                            price: "25",
                            from: "Tunis",
                            to: "Sousse",
                            time: "14:30",
                            date: "28 Nov 2025",
                            places: 3,
                          ),
                          _RideCard(
                            name: "Karim Mansour",
                            price: "22",
                            from: "Tunis",
                            to: "Sousse",
                            time: "16:00",
                            date: "28 Nov 2025",
                            places: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(IconData? icon, String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(label),
        onSelected: (b) {},
        avatar: icon != null ? Icon(icon, size: 18, color: isSelected ? Colors.blue : Colors.grey) : null,
        backgroundColor: const Color(0xFFF6F7FB),
        selectedColor: Colors.blue.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),
    );
  }
}

// --- WIDGET CARTE DE TRAJET ---
class _RideCard extends StatelessWidget {
  final String name, price, from, to, time, date;
  final int places;

  const _RideCard({
    required this.name, required this.price, required this.from,
    required this.to, required this.time, required this.date, required this.places,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.blue, child: Text(name[0], style: const TextStyle(color: Colors.white))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('$places places', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text('$price TND', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, color: Colors.blue, size: 12),
                  Container(width: 2, height: 30, color: Colors.grey[200]),
                  const Icon(Icons.location_on, color: Colors.blue, size: 12),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(from, style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 24),
                  Text(to, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('$date à $time', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // === ACTION DU BOUTON RESERVER ===
                  _showBookingSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Réserver'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- FONCTION POUR AFFICHER LE PANNEAU DE RESERVATION ---
  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingSheet(rideData: {
        'name': name,
        'price': price,
        'from': from,
        'to': to,
        'time': time,
        'date': date,
      }),
    );
  }
}

// --- LE PANNEAU DE RESERVATION (UI INTERNE) ---
class _BookingSheet extends StatefulWidget {
  final Map<String, dynamic> rideData;
  const _BookingSheet({required this.rideData});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  int selectedSeats = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Réserver ce trajet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 20),
          // Résumé rapide
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: const Color(0xFFF6F7FB), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _row('Conducteur', widget.rideData['name']),
                _row('Trajet', "${widget.rideData['from']} → ${widget.rideData['to']}"),
                _row('Date', widget.rideData['date']),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Nombre de places', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) => _seatBtn(index + 1)),
          ),
          const SizedBox(height: 30),
          // Bouton final de paiement
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Réservation confirmée !')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Payer ${(double.parse(widget.rideData['price']) * selectedSeats).toStringAsFixed(2)} TND',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]),
  );

  Widget _seatBtn(int n) {
    bool active = selectedSeats == n;
    return GestureDetector(
      onTap: () => setState(() => selectedSeats = n),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEBF2FF) : Colors.white,
          border: Border.all(color: active ? const Color(0xFF2563EB) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('$n', style: TextStyle(color: active ? const Color(0xFF2563EB) : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}