import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../config/tunisian_cities.dart';
import '../../models/ride.dart';
import '../../providers/ride_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import 'package:intl/intl.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({Key? key}) : super(key: key);

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  
  String? _selectedFromCity;
  String? _selectedToCity;
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  int _availableSeats = 1;
  double _pricePerSeat = 10.0;
  String? _selectedVehicleId;
  
  bool _smokingAllowed = false;
  bool _petsAllowed = false;
  bool _luggageAllowed = false;
  bool _musicAllowed = false;
  bool _conversationAllowed = false;
  
  // Auto-save variables
  Timer? _autoSaveTimer;
  final Map<String, dynamic> _savedData = {};

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _loadVehicles();
    
    // Setup auto-save listeners
    _priceController.addListener(_scheduleAutoSave);
  }
  
  Future<void> _loadVehicles() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    debugPrint('🚗 CreateRide: Current user: ${user?.id} - ${user?.fullName}');
    debugPrint('🚗 CreateRide: Is authenticated: ${auth.isAuthenticated}');
    
    if (user != null && user.id.isNotEmpty) {
      try {
        debugPrint('🚗 CreateRide: Starting vehicle fetch for user: ${user.id}');
        await context.read<VehicleProvider>().fetchMyVehicles(user.id);
        
        // Force UI update after loading
        if (mounted) {
          debugPrint('🚗 CreateRide: Vehicle count after fetch: ${context.read<VehicleProvider>().myVehicles.length}');
          debugPrint('🚗 CreateRide: UI updated after vehicle fetch');
          // Ne pas appeler setState ici, le Consumer se mettra à jour automatiquement
        }
      } catch (e) {
        debugPrint('🚗 CreateRide: Error loading vehicles: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de chargement des véhicules: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } else {
      debugPrint('🚗 CreateRide: No user found or user ID is empty!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez vous connecter pour publier un trajet'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
  
  Future<void> _refreshVehicles() async {
    await _loadVehicles();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Valider que les villes chargées existent dans la liste des villes tunisiennes
      final savedFromCity = prefs.getString('ride_from_city');
      final savedToCity = prefs.getString('ride_to_city');
      
      _selectedFromCity = TunisianCities.cities.contains(savedFromCity) ? savedFromCity : null;
      _selectedToCity = TunisianCities.cities.contains(savedToCity) ? savedToCity : null;
      
      _availableSeats = prefs.getInt('ride_available_seats') ?? 1;
      _pricePerSeat = prefs.getDouble('ride_price_per_seat') ?? 10.0;
      
      // Charger le vehicleId mais le valider plus tard quand les véhicules seront chargés
      final savedVehicleId = prefs.getString('ride_vehicle_id');
      if (savedVehicleId != null && savedVehicleId.isNotEmpty) {
        _selectedVehicleId = savedVehicleId;
      }
      
      _smokingAllowed = prefs.getBool('ride_smoking_allowed') ?? false;
      _petsAllowed = prefs.getBool('ride_pets_allowed') ?? false;
      _luggageAllowed = prefs.getBool('ride_luggage_allowed') ?? false;
      _musicAllowed = prefs.getBool('ride_music_allowed') ?? false;
      _conversationAllowed = prefs.getBool('ride_conversation_allowed') ?? false;
      
      final priceString = prefs.getString('ride_price');
      if (priceString != null) {
        _priceController.text = priceString;
      }
      
      final departureDateMillis = prefs.getInt('ride_departure_date');
      if (departureDateMillis != null) {
        _departureDate = DateTime.fromMillisecondsSinceEpoch(departureDateMillis);
      }
      
      final departureHour = prefs.getInt('ride_departure_hour');
      final departureMinute = prefs.getInt('ride_departure_minute');
      if (departureHour != null && departureMinute != null) {
        _departureTime = TimeOfDay(hour: departureHour, minute: departureMinute);
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ride_from_city', _selectedFromCity ?? '');
    await prefs.setString('ride_to_city', _selectedToCity ?? '');
    await prefs.setInt('ride_available_seats', _availableSeats);
    await prefs.setDouble('ride_price_per_seat', _pricePerSeat);
    await prefs.setString('ride_vehicle_id', _selectedVehicleId ?? '');
    await prefs.setString('ride_price', _priceController.text);
    await prefs.setBool('ride_smoking_allowed', _smokingAllowed);
    await prefs.setBool('ride_pets_allowed', _petsAllowed);
    await prefs.setBool('ride_luggage_allowed', _luggageAllowed);
    await prefs.setBool('ride_music_allowed', _musicAllowed);
    await prefs.setBool('ride_conversation_allowed', _conversationAllowed);
    
    if (_departureDate != null) {
      await prefs.setInt('ride_departure_date', _departureDate!.millisecondsSinceEpoch);
    }
    if (_departureTime != null) {
      await prefs.setInt('ride_departure_hour', _departureTime!.hour);
      await prefs.setInt('ride_departure_minute', _departureTime!.minute);
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      _saveData();
    });
  }

  Future<void> _clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'ride_from_city', 'ride_to_city', 'ride_available_seats', 'ride_price_per_seat',
      'ride_vehicle_id', 'ride_price', 'ride_smoking_allowed', 'ride_pets_allowed',
      'ride_luggage_allowed', 'ride_music_allowed', 'ride_conversation_allowed',
      'ride_departure_date', 'ride_departure_hour', 'ride_departure_minute'
    ];
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _departureDate = picked;
      });
      _scheduleAutoSave();
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _departureTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _departureTime = picked;
      });
      _scheduleAutoSave();
    }
  }

  Future<void> _handleCreateRide() async {
    print('🚗 _handleCreateRide appelé!');
    
    // Validation simple
    if (_selectedFromCity == null || _selectedToCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner les villes'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_departureDate == null || _departureTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner la date et l\'heure'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un véhicule'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un prix'), backgroundColor: Colors.red),
      );
      return;
    }
    
    try {
      print('🚗 Création du trajet...');
      final user = context.read<AuthProvider>().currentUser;
      
      if (user == null) {
        print('🚗 Utilisateur non trouvé');
        return;
      }
      
      final ride = Ride(
        id: '',
        driverId: user.id,
        driverName: user.fullName,
        driverImageUrl: user.profileImageUrl ?? '',
        driverRating: user.rating ?? 0.0,
        fromCity: _selectedFromCity!,
        toCity: _selectedToCity!,
        departureDate: _departureDate!,
        departureTime: _departureTime!,
        availableSeats: _availableSeats,
        totalSeats: _availableSeats,
        pricePerSeat: double.tryParse(_priceController.text) ?? 0.0,
        status: RideStatus.active,
        createdAt: DateTime.now(),
        vehicleId: _selectedVehicleId!,
        preferences: RidePreferences(
          smokingAllowed: _smokingAllowed,
          petsAllowed: _petsAllowed,
          luggageAllowed: _luggageAllowed,
          musicAllowed: _musicAllowed,
          chattingAllowed: _conversationAllowed,
        ),
        vehicleInfo: {
          'brand': '',
          'model': '',
          'color': '',
          'plateNumber': '',
        },
      );

      print('🚗 Appel de createRide...');
      await context.read<RideProvider>().createRide(ride);
      
      print('🚗 Trajet créé avec succès!');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Trajet publié avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Retour à la page précédente
        Navigator.pop(context);
      }
    } catch (e) {
      print('🚗 ERREUR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildPreferenceSwitch(String title, bool value, Function(bool) onChanged, IconData icon) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: AppTheme.primaryBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si l'utilisateur est authentifié
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated || auth.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Publier un trajet'),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Veuillez vous connecter'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publier un trajet'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Publier un trajet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // Ville de départ
          const Text('Ville de départ *'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedFromCity,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Sélectionnez la ville de départ',
            ),
            items: TunisianCities.cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFromCity = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Ville d'arrivée
          const Text('Ville d\'arrivée *'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedToCity,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Sélectionnez la ville d\'arrivée',
            ),
            items: TunisianCities.cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
            onChanged: (value) {
              setState(() {
                _selectedToCity = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Date
          const Text('Date de départ *'),
          const SizedBox(height: 8),
          ListTile(
            title: Text(_departureDate == null ? 'Sélectionner la date' : '${_departureDate!.day}/${_departureDate!.month}/${_departureDate!.year}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectDate,
            tileColor: Colors.grey[100],
          ),
          const SizedBox(height: 16),
          
          // Heure
          const Text('Heure de départ *'),
          const SizedBox(height: 8),
          ListTile(
            title: Text(_departureTime == null ? 'Sélectionner l\'heure' : '${_departureTime!.hour}:${_departureTime!.minute.toString().padLeft(2, '0')}'),
            trailing: const Icon(Icons.access_time),
            onTap: _selectTime,
            tileColor: Colors.grey[100],
          ),
          const SizedBox(height: 16),
          
          // Places
          const Text('Places disponibles *'),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _availableSeats,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Nombre de places',
            ),
            items: List.generate(8, (index) => index + 1).map((seats) => DropdownMenuItem(value: seats, child: Text('$seats places'))).toList(),
            onChanged: (value) {
              setState(() {
                _availableSeats = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Prix
          const Text('Prix par place *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Prix en TND',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Véhicule
          const Text('Véhicule *'),
          const SizedBox(height: 8),
          Consumer<VehicleProvider>(
            builder: (context, vehicleProvider, _) {
              if (vehicleProvider.myVehicles.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Aucun véhicule'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/add-vehicle'),
                          child: const Text('Ajouter un véhicule'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return DropdownButtonFormField<String>(
                value: _selectedVehicleId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Sélectionnez un véhicule',
                ),
                items: vehicleProvider.myVehicles.map((vehicle) => DropdownMenuItem(
                  value: vehicle.id,
                  child: Text('${vehicle.brand} ${vehicle.model}'),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVehicleId = value;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 30),
          
          // Bouton publier
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                print('Bouton cliqué!');
                _handleCreateRide();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('PUBLIER LE TRAJET', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
