import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr');
  String _label = 'Français';

  Locale get locale => _locale;
  String get languageLabel => _label;

  // Helper to force app rebuild after locale change
  static void rebuildApp(BuildContext context) {
    // Force a rebuild by navigating to the same route
    final route = ModalRoute.of(context)?.settings.name;
    if (route != null) {
      Navigator.pushReplacementNamed(context, route);
    } else {
      // Fallback: navigate to home if no route name
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  LocaleProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString('locale_code');
      final label = prefs.getString('locale_label');
      if (code != null) {
        _locale = Locale(code);
        if (label != null) _label = label;
        // best-effort init
        if (code == 'fr') {
          await initializeDateFormatting('fr_FR', null);
        } else if (code == 'ar') {
          await initializeDateFormatting('ar', null);
        } else if (code == 'en') {
          await initializeDateFormatting('en_US', null);
        }
        notifyListeners();
      }
    } catch (_) {
      // ignore errors
    }
  }

  Future<void> setLocale(Locale locale, String label, {bool rebuild = true}) async {
    _locale = locale;
    _label = label;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale_code', locale.languageCode);
      await prefs.setString('locale_label', label);
    } catch (_) {
      // ignore
    }

    // Initialize date formatting for chosen locale (best-effort)
    try {
      if (locale.languageCode == 'fr') {
        await initializeDateFormatting('fr_FR', null);
      } else if (locale.languageCode == 'ar') {
        await initializeDateFormatting('ar', null);
      } else if (locale.languageCode == 'en') {
        await initializeDateFormatting('en_US', null);
      }
    } catch (_) {
      // ignore errors here
    }

    notifyListeners();
  }
}
