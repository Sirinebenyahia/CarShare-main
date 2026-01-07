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
  
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        final userId = authProvider.currentUser?.id;
        if (userId != null) {
          context.read<VehicleProvider>().fetchMyVehicles(userId);
        }
      }
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        final fromCity = prefs.getString('ride_from_city');
        _selectedFromCity = (fromCity != null && fromCity.isNotEmpty) ? fromCity : null;
        
        final toCity = prefs.getString('ride_to_city');
        _selectedToCity = (toCity != null && toCity.isNotEmpty) ? toCity : null;
        
        _availableSeats = prefs.getInt('ride_available_seats') ?? 1;
        _pricePerSeat = prefs.getDouble('ride_price_per_seat') ?? 10.0;
        
        final vehicleId = prefs.getString('ride_vehicle_id');
        _selectedVehicleId = (vehicleId != null && vehicleId.isNotEmpty) ? vehicleId : null;
        
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
    } catch (e) {
      debugPrint('Error loading saved data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
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
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      _saveData();
    });
  }

  Future<void> _clearSavedData() async {
    try {
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
    } catch (e) {
      debugPrint('Error clearing saved data: $e');
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_departureDate == null || _departureTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner la date et l\'heure de départ'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_selectedVehicleId == null || _selectedVehicleId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un véhicule'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    try {
      final user = context.read<AuthProvider>().currentUser;
      final price = double.tryParse(_priceController.text) ?? _pricePerSeat;
      
      final ride = Ride(
        id: '',
        driverId: user?.id ?? '',
        driverName: user?.fullName ?? '',
        driverImageUrl: user?.profileImageUrl ?? '',
        driverRating: user?.rating ?? 0.0,
        fromCity: _selectedFromCity!,
        toCity: _selectedToCity!,
        departureDate: _departureDate!,
        departureTime: _departureTime!,
        availableSeats: _availableSeats,
        totalSeats: _availableSeats,
        pricePerSeat: price,
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

      await context.read<RideProvider>().createRideWithVehicle(ride, _selectedVehicleId!);
      await _clearSavedData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trajet publié avec succès'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.errorRed,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publier un trajet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _saveData();
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Itinéraire'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: TunisianCities.cities.contains(_selectedFromCity) ? _selectedFromCity : null,
                  decoration: InputDecoration(
                    labelText: 'Ville de départ',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: TunisianCities.cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                  onChanged: (value) {
                    setState(() => _selectedFromCity = value);
                    _scheduleAutoSave();
                  },
                  validator: (value) => (value == null || value.isEmpty) ? 'Ville de départ requise' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: TunisianCities.cities.contains(_selectedToCity) ? _selectedToCity : null,
                  decoration: InputDecoration(
                    labelText: 'Ville d\'arrivée',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: TunisianCities.cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                  onChanged: (value) {
                    setState(() => _selectedToCity = value);
                    _scheduleAutoSave();
                  },
                  validator: (value) => (value == null || value.isEmpty) ? 'Ville d\'arrivée requise' : null,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Date et Heure'),
                const SizedBox(height: 12),
                _buildDatePicker(),
                const SizedBox(height: 16),
                _buildTimePicker(),
                const SizedBox(height: 24),
                _buildSectionTitle('Places et Prix'),
                const SizedBox(height: 12),
                _buildSeatsDropdown(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Prix par place (TND) *',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Prix requis';
                    final price = double.tryParse(value);
                    if (price == null || price < 1) return 'Prix invalide';
                    return null;
                  },
                  onChanged: (value) => _scheduleAutoSave(),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Véhicule'),
                const SizedBox(height: 12),
                _buildVehicleDropdown(),
                const SizedBox(height: 24),
                _buildSectionTitle('Préférences'),
                const SizedBox(height: 12),
                _buildPreferenceSwitch('Fumeur autorisé', _smokingAllowed, (v) => setState(() => _smokingAllowed = v), Icons.smoking_rooms),
                _buildPreferenceSwitch('Animaux autorisés', _petsAllowed, (v) => setState(() => _petsAllowed = v), Icons.pets),
                _buildPreferenceSwitch('Bagages autorisés', _luggageAllowed, (v) => setState(() => _luggageAllowed = v), Icons.luggage),
                _buildPreferenceSwitch('Musique autorisée', _musicAllowed, (v) => setState(() => _musicAllowed = v), Icons.music_note),
                _buildPreferenceSwitch('Conversation autorisée', _conversationAllowed, (v) => setState(() => _conversationAllowed = v), Icons.chat),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleCreateRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Publier le trajet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.greyText),
            const SizedBox(width: 12),
            Text(
              _departureDate == null ? 'Date de départ' : DateFormat('dd/MM/yyyy').format(_departureDate!),
              style: TextStyle(fontSize: 16, color: _departureDate == null ? Colors.grey[400] : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppTheme.greyText),
            const SizedBox(width: 12),
            Text(
              _departureTime == null ? 'Heure de départ' : _departureTime!.format(context),
              style: TextStyle(fontSize: 16, color: _departureTime == null ? Colors.grey[400] : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatsDropdown() {
    return DropdownButtonFormField<int>(
      value: (_availableSeats >= 1 && _availableSeats <= 8) ? _availableSeats : 1,
      decoration: InputDecoration(
        labelText: 'Places disponibles',
        prefixIcon: const Icon(Icons.event_seat),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: List.generate(8, (index) => index + 1).map((seats) => DropdownMenuItem(value: seats, child: Text('$seats place${seats > 1 ? 's' : ''}'))).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _availableSeats = value);
          _scheduleAutoSave();
        }
      },
    );
  }

  Widget _buildVehicleDropdown() {
    return Consumer<VehicleProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
        }

        if (provider.myVehicles.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Aucun véhicule trouvé. Vous devez ajouter un véhicule avant de publier.'),
                  TextButton(onPressed: () => Navigator.pushNamed(context, '/add-vehicle'), child: const Text('Ajouter un véhicule')),
                ],
              ),
            ),
          );
        }

        final validVehicleId = provider.myVehicles.any((v) => v.id == _selectedVehicleId) ? _selectedVehicleId : null;

        return DropdownButtonFormField<String>(
          value: validVehicleId,
          decoration: InputDecoration(
            labelText: 'Véhicule *',
            prefixIcon: const Icon(Icons.directions_car),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: provider.myVehicles.map((v) => DropdownMenuItem(value: v.id, child: Text('${v.brand} ${v.model}'))).toList(),
          onChanged: (value) {
            setState(() => _selectedVehicleId = value);
            _scheduleAutoSave();
          },
          validator: (value) => (value == null || value.isEmpty) ? 'Véhicule requis' : null,
        );
      },
    );
  }
}
