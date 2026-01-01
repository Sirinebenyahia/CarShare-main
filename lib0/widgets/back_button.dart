import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackButton extends StatelessWidget {
  final String? fallbackRoute;
  final VoidCallback? customOnPressed;

  const BackButton({
    super.key,
    this.fallbackRoute,
    this.customOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2563EB)),
      onPressed: customOnPressed ?? () {
        // Essayer de revenir en arrière, si impossible aller vers la route de secours
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else if (fallbackRoute != null) {
          context.go(fallbackRoute!);
        } else {
          // Route par défaut si aucune route de secours
          context.go('/home');
        }
      },
      padding: EdgeInsets.zero,
    );
  }
}

class AppBarWithBack extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final String? fallbackRoute;
  final VoidCallback? customOnBackPressed;

  const AppBarWithBack({
    super.key,
    required this.title,
    this.actions,
    this.fallbackRoute,
    this.customOnBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: BackButton(
          fallbackRoute: fallbackRoute,
          customOnPressed: customOnBackPressed,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
