import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final String current;
  final Function(int)? onTap;

  const BottomNav({
    super.key,
    required this.current,
    this.onTap,
  });

  // Logique pour déterminer l'index actif basé sur la route actuelle
  int get _currentIndex {
    switch (current) {
      case 'home':
        return 0;
      case 'search':
        return 1;
      case 'rides':
        return 2;
      case 'profile':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // === DECORATION : OMBRE ET COINS ARRONDIS ===
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, -5), // Ombre portée vers le haut
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed, // Garde les labels fixes
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2563EB), // Bleu identique à votre logo
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0, // On utilise l'ombre du Container à la place
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.grid_view_rounded),
              ),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.search),
              ),
              label: 'Recherche',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.directions_car_filled_outlined),
              ),
              label: 'Trajets',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline),
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}