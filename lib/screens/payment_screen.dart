import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/ride_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.rideId});

  final String rideId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selected = 0;
  bool loading = false;

  Widget _methodTile({
    required int value,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = selected == value;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => selected = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
            width: 1.2,
          ),
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Choisissez votre méthode de paiement', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _methodTile(
              value: 0,
              title: 'Carte Bancaire Locale',
              subtitle: 'Visa, Mastercard - Banques tunisiennes',
            ),
            const SizedBox(height: 10),
            _methodTile(
              value: 1,
              title: 'Orange Money',
              subtitle: 'Paiement mobile sécurisé',
            ),
            const SizedBox(height: 10),
            _methodTile(
              value: 2,
              title: 'Ooredoo Money',
              subtitle: 'Services financiers mobiles',
            ),
            const SizedBox(height: 10),
            _methodTile(
              value: 3,
              title: 'Paiement en Espèces',
              subtitle: 'Directement au chauffeur',
            ),
            const Spacer(),
            FilledButton(
              onPressed: loading
                  ? null
                  : () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        if (!context.mounted) return;
                        context.go('/welcome');
                        return;
                      }

                      setState(() => loading = true);
                      try {
                        final method = switch (selected) {
                          0 => 'card',
                          1 => 'orange_money',
                          2 => 'ooredoo_money',
                          _ => 'cash',
                        };

                        await RideService().createBooking(
                          rideId: widget.rideId,
                          userId: user.uid,
                          paymentMethod: method,
                        );

                        if (!context.mounted) return;
                        context.go('/upcoming-rides');
                      } finally {
                        if (mounted) setState(() => loading = false);
                      }
                    },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Confirmer le paiement'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
