import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/tunisian_cities.dart';
import '../../models/ride.dart';
import '../../providers/ride_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';

class EditRideScreen extends StatefulWidget {
  final Ride ride;

  const EditRideScreen({Key? key, required this.ride}) : super(key: key);

  @override
  State<EditRideScreen> createState() => _EditRideScreenState();
}

class _EditRideScreenState extends State<EditRideScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Variables avec valeurs par défaut
  String _selectedFromCity = '';
  String _selectedToCity = '';
  DateTime _departureDate = DateTime.now();
  TimeOfDay _departureTime = const TimeOfDay(hour: 8, minute: 0);
  int _availableSeats = 1;
  double _pricePerSeat = 10.0;
  String _selectedVehicleId = '';
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  bool _smokingAllowed = false;
  bool _petsAllowed = false;
  bool _luggageAllowed = true;
  bool _musicAllowed = true;
  bool _conversationAllowed = true;

  @override
  void initState() {
    super.initState();
    // Initialiser avec les données du trajet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFields();
    });
  }
  
  void _initializeFields() {
    final ride = widget.ride;
    
    setState(() {
      _selectedFromCity = ride.fromCity;
      _selectedToCity = ride.toCity;
      _departureDate = ride.departureDate;
      _departureTime = ride.departureTime;
      _availableSeats = ride.availableSeats;
      _pricePerSeat = ride.pricePerSeat;
      _selectedVehicleId = ride.vehicleId ?? '';
      _descriptionController.text = ride.description ?? '';
      _priceController.text = ride.pricePerSeat.toStringAsFixed(2);
      
      _smokingAllowed = ride.preferences?.smokingAllowed ?? false;
      _petsAllowed = ride.preferences?.petsAllowed ?? false;
      _luggageAllowed = ride.preferences?.luggageAllowed ?? true;
      _musicAllowed = ride.preferences?.musicAllowed ?? true;
      _conversationAllowed = ride.preferences?.chattingAllowed ?? true;
    });
  }
  
  Future<void> _updateRide() async {
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Utilisateur non connecté'), backgroundColor: Colors.red),
        );
        return;
      }
      
      // Validation simple
      if (_selectedFromCity.isEmpty || _selectedToCity.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner les villes'), backgroundColor: Colors.red),
        );
        return;
      }
      
      if (_selectedVehicleId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un véhicule'), backgroundColor: Colors.red),
        );
        return;
      }
      
      // Mettre à jour le trajet
      await context.read<RideProvider>().updateRide(
        widget.ride.id,
        {
          'fromCity': _selectedFromCity,
          'toCity': _selectedToCity,
          'departureDate': _departureDate.toIso8601String(),
          'departureTime': {
            'hour': _departureTime.hour,
            'minute': _departureTime.minute,
          },
          'availableSeats': _availableSeats,
          'pricePerSeat': double.tryParse(_priceController.text) ?? _pricePerSeat,
          'vehicleId': _selectedVehicleId,
          'description': _descriptionController.text.trim(),
          'preferences': {
            'smokingAllowed': _smokingAllowed,
            'petsAllowed': _petsAllowed,
            'luggageAllowed': _luggageAllowed,
            'musicAllowed': _musicAllowed,
            'chattingAllowed': _conversationAllowed,
          },
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Trajet mis à jour avec succès!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le trajet'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Modifier le trajet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // Ville de départ
          const Text('Ville de départ *'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedFromCity.isEmpty ? null : _selectedFromCity,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Sélectionnez la ville de départ',
            ),
            items: TunisianCities.cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedFromCity = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Ville d'arrivée
          const Text('Ville d\'arrivée *'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedToCity.isEmpty ? null : _selectedToCity,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Sélectionnez la ville d\'arrivée',
            ),
            items: TunisianCities.cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedToCity = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Date
          const Text('Date de départ *'),
          const SizedBox(height: 8),
          ListTile(
            title: Text('${_departureDate.day}/${_departureDate.month}/${_departureDate.year}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _departureDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _departureDate = picked;
                });
              }
            },
            tileColor: Colors.grey[100],
          ),
          const SizedBox(height: 16),
          
          // Heure
          const Text('Heure de départ *'),
          const SizedBox(height: 8),
          ListTile(
            title: Text('${_departureTime.hour}:${_departureTime.minute.toString().padLeft(2, '0')}'),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _departureTime,
              );
              if (picked != null) {
                setState(() {
                  _departureTime = picked;
                });
              }
            },
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
              if (value != null) {
                setState(() {
                  _availableSeats = value;
                });
              }
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
                value: _selectedVehicleId.isEmpty ? null : _selectedVehicleId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Sélectionnez un véhicule',
                ),
                items: vehicleProvider.myVehicles.map((vehicle) => DropdownMenuItem(
                  value: vehicle.id,
                  child: Text('${vehicle.brand} ${vehicle.model}'),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedVehicleId = value;
                    });
                  }
                },
              );
            },
          ),
          const SizedBox(height: 16),
          
          // Description
          const Text('Description'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Décrivez votre trajet...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          
          // Préférences
          const Text('Préférences'),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Fumeur autorisé'),
            value: _smokingAllowed,
            onChanged: (value) => setState(() => _smokingAllowed = value),
          ),
          SwitchListTile(
            title: const Text('Animaux autorisés'),
            value: _petsAllowed,
            onChanged: (value) => setState(() => _petsAllowed = value),
          ),
          SwitchListTile(
            title: const Text('Bagages autorisés'),
            value: _luggageAllowed,
            onChanged: (value) => setState(() => _luggageAllowed = value),
          ),
          SwitchListTile(
            title: const Text('Musique autorisée'),
            value: _musicAllowed,
            onChanged: (value) => setState(() => _musicAllowed = value),
          ),
          SwitchListTile(
            title: const Text('Conversation autorisée'),
            value: _conversationAllowed,
            onChanged: (value) => setState(() => _conversationAllowed = value),
          ),
          const SizedBox(height: 32),
          
          // Bouton de mise à jour
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _updateRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('METTRE À JOUR LE TRAJET', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
