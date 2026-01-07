import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../config/theme.dart';
import '../../config/tunisian_cities.dart';
import '../../models/ride.dart';
import '../../providers/ride_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class EditRideScreen extends StatefulWidget {
  final Ride ride;

  const EditRideScreen({Key? key, required this.ride}) : super(key: key);

  @override
  State<EditRideScreen> createState() => _EditRideScreenState();
}

class _EditRideScreenState extends State<EditRideScreen> {
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
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
    
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

  void _initializeFormData() {
    final ride = widget.ride;
    
    setState(() {
      _selectedFromCity = ride.fromCity;
      _selectedToCity = ride.toCity;
      _departureDate = ride.departureDate;
      _departureTime = ride.departureTime;
      _availableSeats = ride.availableSeats;
      _pricePerSeat = ride.pricePerSeat;
      _selectedVehicleId = ride.vehicleId;
      
      _priceController.text = ride.pricePerSeat.toStringAsFixed(2);
      
      _smokingAllowed = ride.preferences?.smokingAllowed ?? false;
      _petsAllowed = ride.preferences?.petsAllowed ?? false;
      _luggageAllowed = ride.preferences?.luggageAllowed ?? false;
      _musicAllowed = ride.preferences?.musicAllowed ?? false;
      _conversationAllowed = ride.preferences?.chattingAllowed ?? false;
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _departureDate = picked;
      });
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
    }
  }

  Future<void> _handleUpdateRide() async {
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

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthProvider>().currentUser;
      final price = double.tryParse(_priceController.text) ?? _pricePerSeat;
      
      final updatedRide = widget.ride.copyWith(
        fromCity: _selectedFromCity!,
        toCity: _selectedToCity!,
        departureDate: _departureDate!,
        departureTime: _departureTime!,
        availableSeats: _availableSeats,
        totalSeats: _availableSeats,
        pricePerSeat: price,
        vehicleId: _selectedVehicleId!,
        preferences: RidePreferences(
          smokingAllowed: _smokingAllowed,
          petsAllowed: _petsAllowed,
          luggageAllowed: _luggageAllowed,
          musicAllowed: _musicAllowed,
          chattingAllowed: _conversationAllowed,
        ),
        updatedAt: DateTime.now(),
      );

      await context.read<RideProvider>().updateRide(widget.ride.id, {
        'fromCity': _selectedFromCity!,
        'toCity': _selectedToCity!,
        'departureDate': _departureDate!.toIso8601String(),
        'departureTime': {
          'hour': _departureTime!.hour,
          'minute': _departureTime!.minute,
        },
        'availableSeats': _availableSeats,
        'totalSeats': _availableSeats,
        'pricePerSeat': price,
        'vehicleId': _selectedVehicleId!,
        'preferences': {
          'smokingAllowed': _smokingAllowed,
          'petsAllowed': _petsAllowed,
          'luggageAllowed': _luggageAllowed,
          'musicAllowed': _musicAllowed,
          'chattingAllowed': _conversationAllowed,
        },
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trajet modifié avec succès'),
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
        title: const Text('Modifier le trajet'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
                          onPressed: _handleUpdateRide,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Mettre à jour le trajet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  const Text('Aucun véhicule trouvé.'),
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
          },
          validator: (value) => (value == null || value.isEmpty) ? 'Véhicule requis' : null,
        );
      },
    );
  }
}
