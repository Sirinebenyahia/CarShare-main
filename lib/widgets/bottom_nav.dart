import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.current});

  final String current;

  int get _currentIndex {
    switch (current) {
      case 'home':
        return 0;
      case 'rides':
        return 1;
      case 'history':
        return 2;
      case 'profile':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            return;
          case 1:
            context.go('/upcoming-rides');
            return;
          case 2:
            context.go('/history');
            return;
          case 3:
            context.go('/profile');
            return;
          default:
            context.go('/home');
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Recherche',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Trajets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Historique',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}
