import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Avis')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final reviewsQuery = FirebaseFirestore.instance
        .collection('reviews')
        .where('toUserId', isEqualTo: user.id)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Avis et évaluations')),
      body: StreamBuilder<QuerySnapshot>(
        stream: reviewsQuery,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Aucun avis pour le moment'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
              final comment = data['comment'] as String? ?? '';
              final from = data['fromUserName'] as String? ?? 'Utilisateur';

              return ListTile(
                leading: CircleAvatar(
                  child: Text(rating.toStringAsFixed(1)),
                ),
                title: Text(from),
                subtitle: Text(comment),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(rating.toStringAsFixed(1)),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
