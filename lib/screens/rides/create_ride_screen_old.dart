import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/ride.dart';
import '../../models/vehicle.dart';
import '../../config/theme.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'package:intl/intl.dart';
import '../../config/constants.dart';
import '../../models/ride.dart';
import '../../config/tunisian_cities.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({Key? key}) : super(key: key);

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedFromCity;
  String? _selectedToCity;
  final _departureDateController = TextEditingController();
  final _departureTimeController = TextEditingController(text: '08:00');
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController(text: '4');
  final _descriptionController = TextEditingController();
  
  String? _selectedVehicleId;
  Vehicle? _selectedVehicle;
  List<Vehicle> _myVehicles = [];
  
  bool _isLoading = false;
  bool _isExpanded = false;
  bool _luggageAllowed = true;
  bool _musicAllowed = true;
  bool _chattingAllowed = true;
  bool _smokingAllowed = true;
  bool _petsAllowed = true;
  
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  String? _fromCity;
  String? _toCity;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      await context.read<VehicleProvider>().fetchMyVehicles(userId);
    }
  }

  @override
  void dispose() {
    _seatsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _departureDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _departureTime = picked);
    }
  }

  Future<void> _handleCreateRide() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFromCity == null || _selectedToCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les villes'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_selectedFromCity == _selectedToCity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les villes de départ et d\'arrivée doivent être différentes'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un véhicule'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_departureDate == null || _departureTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner la date et l\'heure'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser!;


    try {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId == null) return;

      // Créer le ride avec les infos du véhicule
      final rideId = await context.read<RideProvider>().createRideWithVehicle(
        Ride(
          id: '',
          driverId: userId,
          fromCity: _selectedFromCity!,
          toCity: _selectedToCity!,
          departureDate: DateTime(
            _departureDate!.year,
            _departureDate!.month,
            _departureDate!.day,
            _departureTime!.hour,
            _departureTime!.minute,
          ),
          pricePerSeat: double.parse(_priceController.text),
          availableSeats: int.parse(_seatsController.text),
          description: _descriptionController.text.trim(),
          preferences: RidePreferences(
            luggageAllowed: _luggageAllowed,
            musicAllowed: _musicAllowed,
            chattingAllowed: _chattingAllowed,
          ),
          status: RideStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        _selectedVehicleId!, // Utiliser le véhicule sélectionné
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trajet créé avec succès!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publier un trajet'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Itinéraire
                _buildSectionTitle('Itinéraire'),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _selectedFromCity,
                  decoration: InputDecoration(
                    labelText: 'Ville de départ',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: TunisianCities.cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFromCity = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ville de départ requise';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedToCity,
                  decoration: InputDecoration(
                    labelText: 'Ville d\'arrivée',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: TunisianCities.cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedToCity = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ville d\'arrivée requise';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppTheme.greyText),
                        const SizedBox(width: 12),
                        Text(
                          _departureDate == null
                              ? 'Date de départ'
                              : '${_departureDate!.day}/${_departureDate!.month}/${_departureDate!.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: _departureDate == null
                                ? Colors.grey[400]
                                : Colors.black,
                return Column(
                  children: [
                    if (vehicleProvider.isLoading) ...[
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 16),
                              Text('Chargement des véhicules...'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (vehicleProvider.myVehicles.isEmpty) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.directions_car, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              const Text('Aucun véhicule enregistré'),
                              const SizedBox(height: 8),
                              const Text('Vous devez ajouter un véhicule avant de publier un trajet'),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/add-vehicle');
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter un véhicule'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (vehicleProvider.myVehicles.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedVehicleId,
                        decoration: InputDecoration(
                          labelText: 'Véhicule *',
                          prefixIcon: const Icon(Icons.directions_car),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorStyle: const TextStyle(color: AppTheme.errorRed),
                        ),
                        items: vehicleProvider.myVehicles.where((vehicle) => vehicle.id != null && vehicle.brand != null && vehicle.model != null).map((vehicle) {
                          return DropdownMenuItem(
                            value: vehicle.id,
                            child: Row(
                              children: [
                                const Icon(Icons.directions_car, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${vehicle.brand ?? ''} ${vehicle.model ?? ''}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null && value != _selectedVehicleId) {
                            _selectedVehicleId = value;
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un véhicule';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Section: Préférences
            _buildSectionTitle('Préférences'),
            const SizedBox(height: 12),

            _buildPreferenceSwitch(
              'Fumeur autorisé',
              _smokingAllowed,
              (value) => setState(() => _smokingAllowed = value),
              Icons.smoking_rooms,
            ),
            _buildPreferenceSwitch(
              'Animaux autorisés',
              _petsAllowed,
              (value) => setState(() => _petsAllowed = value),
              Icons.pets,
            ),
            _buildPreferenceSwitch(
              'Bagages autorisés',
              _luggageAllowed,
              (value) => setState(() => _luggageAllowed = value),
              Icons.luggage,
            ),
            _buildPreferenceSwitch(
              'Musique autorisée',
              _musicAllowed,
              (value) => setState(() => _musicAllowed = value),
              Icons.music_note,
            ),
            _buildPreferenceSwitch(
              'Discussion autorisée',
              _chattingAllowed,
              (value) => setState(() => _chattingAllowed = value),
              Icons.chat,
            ),

            const SizedBox(height: 32),

            // Create Button
            CustomButton(
              text: 'Publier le trajet',
              icon: Icons.check,
              onPressed: _handleCreateRide,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPreferenceSwitch(
    String label,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.greyText, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }
}
