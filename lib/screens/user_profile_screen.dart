import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non connecté')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Profil introuvable'));
            }

            final Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;

            final String fullName =
                (data['fullName'] ?? user.email ?? 'Utilisateur').toString();
            final String role =
                (data['role'] ?? 'Passager').toString();

            final int trips =
                (data['tripsCount'] is int) ? data['tripsCount'] : 0;

            final int reliability =
                (data['reliability'] is int) ? data['reliability'] : 0;

            final DateTime memberSince = data['memberSince'] is Timestamp
                ? (data['memberSince'] as Timestamp).toDate()
                : DateTime.now();

            final Map<String, dynamic> wilayas =
                data['wilayas'] is Map<String, dynamic>
                    ? Map<String, dynamic>.from(data['wilayas'])
                    : {};

            final String initials = fullName
                .split(' ')
                .where((e) => e.isNotEmpty)
                .take(2)
                .map((e) => e[0])
                .join()
                .toUpperCase();

            return SingleChildScrollView(
              child: Column(
                children: [
                  // ===== HEADER =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Mon Profil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.settings, color: Colors.white),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== PROFIL CARD =====
                  _ProfileCard(
                    initials: initials,
                    fullName: fullName,
                    role: role,
                    trips: trips,
                    reliability: reliability,
                    memberYears:
                        DateTime.now().year - memberSince.year,
                  ),

                  const SizedBox(height: 20),

                  // ===== WILAYAS =====
                  _WilayasCard(wilayas: wilayas),

                  const SizedBox(height: 24),

                  // ===== LOGOUT =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Se déconnecter'),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          context.go('/welcome');
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/* ======================
   WIDGETS PRIVÉS UI
   ====================== */

class _ProfileCard extends StatelessWidget {
  final String initials;
  final String fullName;
  final String role;
  final int trips;
  final int reliability;
  final int memberYears;

  const _ProfileCard({
    required this.initials,
    required this.fullName,
    required this.role,
    required this.trips,
    required this.reliability,
    required this.memberYears,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF2563EB),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(role, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(value: trips.toString(), label: 'Trajets'),
              _Stat(value: '$reliability%', label: 'Fiabilité'),
              _Stat(value: '$memberYears ans', label: 'Membre'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}

class _WilayasCard extends StatelessWidget {
  final Map<String, dynamic> wilayas;

  const _WilayasCard({required this.wilayas});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wilayas fréquemment visitées',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...wilayas.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key.toString()),
                  Text(
                    '${entry.value.toString()} trajets',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
