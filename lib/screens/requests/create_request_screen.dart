import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../config/tunisian_cities.dart';
import '../../models/ride_request.dart';
import '../../providers/ride_request_provider.dart';
import '../../providers/auth_provider.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({Key? key}) : super(key: key);

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _messageController = TextEditingController();
  
  String? _selectedFromCity;
  String? _selectedToCity;
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  int _passengers = 1;
  double _maxPrice = 50.0;
  bool _smokingAllowed = false;
  bool _petsAllowed = false;
  bool _luggageAllowed = true;
  bool _musicAllowed = true;
  bool _conversationAllowed = true;
  
  // Auto-save variables
  Timer? _autoSaveTimer;
  final Map<String, dynamic> _savedData = {};
  
  @override
  void initState() {
    super.initState();
    _loadSavedData();
    
    // Setup auto-save listeners
    _priceController.addListener(_scheduleAutoSave);
    _messageController.addListener(_scheduleAutoSave);
  }
  
  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFromCity = prefs.getString('request_from_city');
      _selectedToCity = prefs.getString('request_to_city');
      _priceController.text = prefs.getString('request_price') ?? '';
      _messageController.text = prefs.getString('request_message') ?? '';
      _passengers = prefs.getInt('request_passengers') ?? 1;
      _maxPrice = prefs.getDouble('request_max_price') ?? 50.0;
      _smokingAllowed = prefs.getBool('request_smoking') ?? false;
      _petsAllowed = prefs.getBool('request_pets') ?? false;
      _luggageAllowed = prefs.getBool('request_luggage') ?? true;
      _musicAllowed = prefs.getBool('request_music') ?? true;
      _conversationAllowed = prefs.getBool('request_conversation') ?? true;
      
      // Load date and time
      final dateStr = prefs.getString('request_date');
      final timeStr = prefs.getString('request_time');
      if (dateStr != null) {
        _departureDate = DateTime.tryParse(dateStr);
      }
      if (timeStr != null) {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          _departureTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    });
  }
  
  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      _saveData();
    });
  }
  
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_selectedFromCity != null) await prefs.setString('request_from_city', _selectedFromCity!);
    if (_selectedToCity != null) await prefs.setString('request_to_city', _selectedToCity!);
    await prefs.setString('request_price', _priceController.text);
    await prefs.setString('request_message', _messageController.text);
    await prefs.setInt('request_passengers', _passengers);
    await prefs.setDouble('request_max_price', _maxPrice);
    await prefs.setBool('request_smoking', _smokingAllowed);
    await prefs.setBool('request_pets', _petsAllowed);
    await prefs.setBool('request_luggage', _luggageAllowed);
    await prefs.setBool('request_music', _musicAllowed);
    await prefs.setBool('request_conversation', _conversationAllowed);
    
    if (_departureDate != null) {
      await prefs.setString('request_date', _departureDate!.toIso8601String());
    }
    if (_departureTime != null) {
      await prefs.setString('request_time', '${_departureTime!.hour}:${_departureTime!.minute}');
    }
  }
  
  Future<void> _clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('request_from_city');
    await prefs.remove('request_to_city');
    await prefs.remove('request_price');
    await prefs.remove('request_message');
    await prefs.remove('request_passengers');
    await prefs.remove('request_max_price');
    await prefs.remove('request_smoking');
    await prefs.remove('request_pets');
    await prefs.remove('request_luggage');
    await prefs.remove('request_music');
    await prefs.remove('request_conversation');
    await prefs.remove('request_date');
    await prefs.remove('request_time');
    
    setState(() {
      _selectedFromCity = null;
      _selectedToCity = null;
      _priceController.clear();
      _messageController.clear();
      _passengers = 1;
      _maxPrice = 50.0;
      _smokingAllowed = false;
      _petsAllowed = false;
      _luggageAllowed = true;
      _musicAllowed = true;
      _conversationAllowed = true;
      _departureDate = null;
      _departureTime = null;
    });
  }
  
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedFromCity == null || _selectedToCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner les villes de départ et d\'arrivée')),
      );
      return;
    }
    
    if (_departureDate == null || _departureTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner la date et l\'heure de départ')),
      );
      return;
    }
    
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    
    try {
      final request = RideRequest(
        id: '', // Will be set by provider
        passengerId: user.id,
        passengerName: user.fullName,
        passengerAvatar: user.profileImageUrl ?? '',
        passengerRating: user.rating ?? 0.0,
        origin: _selectedFromCity!,
        destination: _selectedToCity!,
        departureDate: _departureDate!,
        departureTime: _departureTime!,
        seatsNeeded: _passengers,
        maxPrice: _maxPrice,
        notes: _messageController.text.trim(),
        status: RideRequestStatus.active,
        createdAt: DateTime.now(),
        proposals: [],
      );
      
      await context.read<RideRequestProvider>().createRequest(request);
      
      // Clear saved data after successful submission
      await _clearData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande créée avec succès!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une demande'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Effacer les données'),
                  content: const Text('Voulez-vous effacer toutes les données du formulaire?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Effacer'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true) {
                await _clearData();
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route section
              _buildSectionTitle('Itinéraire'),
              _buildCitySelection(),
              const SizedBox(height: 24),
              
              // Date and time
              _buildSectionTitle('Date et heure'),
              _buildDateTimeSelection(),
              const SizedBox(height: 24),
              
              // Price and passengers
              _buildSectionTitle('Budget et passagers'),
              _buildPriceAndPassengers(),
              const SizedBox(height: 24),
              
              // Preferences
              _buildSectionTitle('Préférences'),
              _buildPreferences(),
              const SizedBox(height: 24),
              
              // Message
              _buildSectionTitle('Message (optionnel)'),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Décrivez votre demande...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Créer la demande'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
  
  Widget _buildCitySelection() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedFromCity,
            decoration: const InputDecoration(
              labelText: 'Ville de départ',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
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
                _scheduleAutoSave();
              });
            },
            validator: (value) => value == null ? 'Champ obligatoire' : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedToCity,
            decoration: const InputDecoration(
              labelText: 'Ville d\'arrivée',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag),
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
                _scheduleAutoSave();
              });
            },
            validator: (value) => value == null ? 'Champ obligatoire' : null,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDateTimeSelection() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _departureDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _departureDate = date;
                  _scheduleAutoSave();
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date de départ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                _departureDate != null
                    ? '${_departureDate!.day}/${_departureDate!.month}/${_departureDate!.year}'
                    : 'Sélectionner une date',
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _departureTime ?? const TimeOfDay(hour: 8, minute: 0),
              );
              if (time != null) {
                setState(() {
                  _departureTime = time;
                  _scheduleAutoSave();
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Heure de départ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
              child: Text(
                _departureTime != null
                    ? '${_departureTime!.hour.toString().padLeft(2, '0')}:${_departureTime!.minute.toString().padLeft(2, '0')}'
                    : 'Sélectionner une heure',
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPriceAndPassengers() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Prix maximum (TND)'),
              const SizedBox(height: 8),
              Slider(
                value: _maxPrice,
                min: 10,
                max: 200,
                divisions: 19,
                onChanged: (value) {
                  setState(() {
                    _maxPrice = value;
                    _scheduleAutoSave();
                  });
                },
              ),
              Text(
                '${_maxPrice.toInt()} TND',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nombre de passagers'),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: _passengers > 1
                        ? () {
                            setState(() {
                              _passengers--;
                              _scheduleAutoSave();
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    '$_passengers',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _passengers < 8
                        ? () {
                            setState(() {
                              _passengers++;
                              _scheduleAutoSave();
                            });
                          }
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPreferences() {
    return Column(
      children: [
        _buildPreferenceTile('Fumeur autorisé', _smokingAllowed, (value) {
          setState(() {
            _smokingAllowed = value;
            _scheduleAutoSave();
          });
        }),
        _buildPreferenceTile('Animaux autorisés', _petsAllowed, (value) {
          setState(() {
            _petsAllowed = value;
            _scheduleAutoSave();
          });
        }),
        _buildPreferenceTile('Bagages autorisés', _luggageAllowed, (value) {
          setState(() {
            _luggageAllowed = value;
            _scheduleAutoSave();
          });
        }),
        _buildPreferenceTile('Musique autorisée', _musicAllowed, (value) {
          setState(() {
            _musicAllowed = value;
            _scheduleAutoSave();
          });
        }),
        _buildPreferenceTile('Conversation souhaitée', _conversationAllowed, (value) {
          setState(() {
            _conversationAllowed = value;
            _scheduleAutoSave();
          });
        }),
      ],
    );
  }
  
  Widget _buildPreferenceTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryBlue,
    );
  }
}
