import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/ride.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({Key? key}) : super(key: key);

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _fromCity;
  String? _toCity;
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  final _seatsController = TextEditingController(text: '3');
  final _priceController = TextEditingController(text: '20');
  String? _selectedVehicleId;
  
  // Preferences
  bool _smokingAllowed = false;
  bool _petsAllowed = false;
  bool _luggageAllowed = true;
  bool _musicAllowed = true;
  bool _chattingAllowed = true;

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      context.read<VehicleProvider>().fetchMyVehicles(userId);
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

    if (_fromCity == null || _toCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les villes'),
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

    final ride = Ride(
      id: '',
      driverId: user.id,
      driverName: user.fullName,
      driverImageUrl: user.profileImageUrl,
      driverRating: user.rating,
      fromCity: _fromCity!,
      toCity: _toCity!,
      departureDate: _departureDate!,
      departureTime: '${_departureTime!.hour.toString().padLeft(2, '0')}:${_departureTime!.minute.toString().padLeft(2, '0')}',
      availableSeats: int.parse(_seatsController.text),
      totalSeats: int.parse(_seatsController.text),
      pricePerSeat: double.parse(_priceController.text),
      vehicleId: _selectedVehicleId,
      preferences: RidePreferences(
        smokingAllowed: _smokingAllowed,
        petsAllowed: _petsAllowed,
        luggageAllowed: _luggageAllowed,
        musicAllowed: _musicAllowed,
        chattingAllowed: _chattingAllowed,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await context.read<RideProvider>().createRide(ride);

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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section: Itinéraire
            _buildSectionTitle('Itinéraire'),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _fromCity,
              decoration: InputDecoration(
                labelText: 'Ville de départ',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: AppConstants.tunisianCities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) => setState(() => _fromCity = value),
              validator: (value) =>
                  value == null ? 'Ville de départ requise' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _toCity,
              decoration: InputDecoration(
                labelText: 'Ville d\'arrivée',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: AppConstants.tunisianCities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) => setState(() => _toCity = value),
              validator: (value) =>
                  value == null ? 'Ville d\'arrivée requise' : null,
            ),
            const SizedBox(height: 24),

            // Section: Date et Heure
            _buildSectionTitle('Date et Heure'),
            const SizedBox(height: 12),

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
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: AppTheme.greyText),
                    const SizedBox(width: 12),
                    Text(
                      _departureTime == null
                          ? 'Heure de départ'
                          : '${_departureTime!.hour.toString().padLeft(2, '0')}:${_departureTime!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _departureTime == null
                            ? Colors.grey[400]
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section: Détails
            _buildSectionTitle('Détails'),
            const SizedBox(height: 12),

            CustomTextField(
              controller: _seatsController,
              label: 'Nombre de places disponibles',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.event_seat,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nombre de places requis';
                }
                final number = int.tryParse(value);
                if (number == null || number < 1 || number > 8) {
                  return 'Entre 1 et 8 places';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _priceController,
              label: 'Prix par place (TND)',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Prix requis';
                }
                final price = double.tryParse(value);
                if (price == null || price < 1) {
                  return 'Prix invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Vehicle Selection
            Consumer<VehicleProvider>(
              builder: (context, vehicleProvider, _) {
                if (vehicleProvider.myVehicles.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Aucun véhicule enregistré'),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/add-vehicle');
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter un véhicule'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: _selectedVehicleId,
                  decoration: InputDecoration(
                    labelText: 'Véhicule',
                    prefixIcon: const Icon(Icons.directions_car),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: vehicleProvider.myVehicles.map((vehicle) {
                    return DropdownMenuItem(
                      value: vehicle.id,
                      child: Text('${vehicle.brand} ${vehicle.model}'),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedVehicleId = value),
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
