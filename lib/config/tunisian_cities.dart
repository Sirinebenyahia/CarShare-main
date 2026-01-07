class TunisianCities {
  static const List<String> cities = [
    'Tunis',
    'Sfax',
    'Sousse',
    'Kairouan',
    'Bizerte',
    'Gabès',
    'Ariana',
    'Béja',
    'Ben Arous',
    'Gafsa',
    'Jendouba',
    'Kasserine',
    'Kébili',
    'Le Kef',
    'Mahdia',
    'Manouba',
    'Médenine',
    'Monastir',
    'Nabeul',
    'Sidi Bouzid',
    'Siliana',
    'Tataouine',
    'Tozeur',
    'Zaghouan',
  ];

  static List<String> getSuggestions(String query) {
    final List<String> matches = [];
    for (var city in cities) {
      if (city.toLowerCase().contains(query.toLowerCase())) {
        matches.add(city);
      }
    }
    return matches;
  }
}
