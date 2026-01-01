import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../services/ride_service.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key, required this.bookingId});

  final String bookingId;
  static final RideService _rideService = RideService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Ma Réservation',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2563EB), size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _rideService.bookingStream(bookingId),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Erreur: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final booking = snap.data!.data();
          if (booking == null) return const Center(child: Text('Réservation introuvable.'));

          final rideId = (booking['rideId'] ?? '').toString();
          final method = (booking['paymentMethod'] ?? 'wallet').toString();
          final totalPrice = (booking['totalPrice'] ?? 0.0).toDouble();
          final seatCount = booking['seatCount'] ?? 1;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Infos Trajet
                _buildRideHeader(rideId),

                const SizedBox(height: 24),
                const Text("Nombre de places", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildStaticSeatDisplay(seatCount),

                const SizedBox(height: 24),
                const Text("Méthode de paiement", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // 2. LES DEUX CHOIX UNIQUEMENT (Portefeuille ou Espèces)
                if (method == 'wallet')
                  _buildPaymentMethodCard(
                    title: "Portefeuille CarShare",
                    subtitle: "Solde: 125.50 TND",
                    icon: Icons.account_balance_wallet_outlined,
                    isWallet: true,
                  )
                else
                  _buildPaymentMethodCard(
                    title: "Paiement en espèces",
                    subtitle: "Payé au conducteur",
                    icon: Icons.payments_outlined,
                    isWallet: false,
                  ),

                const SizedBox(height: 24),

                // 3. Barre de total
                _buildTotalSummaryBar(totalPrice, seatCount),

                const SizedBox(height: 32),

                // Bouton Vert de confirmation d'état
                _buildConfirmedButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET : CARTE DE PAIEMENT (DESIGN IDENTIQUE À VOS IMAGES) ---
  Widget _buildPaymentMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isWallet,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF2563EB), width: 2), // Bordure bleue de sélection
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isWallet ? Colors.green : Colors.grey, // Solde en vert
                    fontSize: 12,
                    fontWeight: isWallet ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF2563EB)), // Icône check à droite
        ],
      ),
    );
  }

  // --- WIDGET : AFFICHAGE DES PLACES (STYLE IMAGE 1) ---
  Widget _buildStaticSeatDisplay(int selected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        int n = index + 1;
        bool isActive = n == selected;
        return Container(
          width: 75,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEBF2FF) : Colors.white,
            border: Border.all(
              color: isActive ? const Color(0xFF2563EB) : Colors.grey.shade200,
              width: isActive ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.people_outline, color: isActive ? Colors.blue : Colors.grey, size: 20),
              Text("$n", style: TextStyle(
                  color: isActive ? Colors.blue : Colors.black,
                  fontWeight: FontWeight.bold
              )),
            ],
          ),
        );
      }),
    );
  }

  // --- AUTRES COMPOSANTS VISUELS ---

  Widget _buildRideHeader(String rideId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _rideService.rideStream(rideId),
      builder: (context, snap) {
        final ride = snap.data?.data() ?? {};
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              _infoRow("Conducteur", ride['driverName'] ?? "Chargement..."),
              const SizedBox(height: 10),
              _infoRow("Trajet", "${ride['from'] ?? ''} → ${ride['to'] ?? ''}"),
              const SizedBox(height: 10),
              _infoRow("Date", ride['date'] ?? "--"),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: Colors.grey)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );

  Widget _buildTotalSummaryBar(double total, int seats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total payé', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('${total.toStringAsFixed(2)} TND',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          Text('$seats place(s)\n${(total/seats).toInt()} TND / place',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildConfirmedButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFF00B050),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text('Réservation confirmée',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}