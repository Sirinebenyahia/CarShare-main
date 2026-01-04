import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/vehicle.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({Key? key}) : super(key: key);

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _brand;
  final _modelController = TextEditingController();
  String? _color;
  final _licensePlateController = TextEditingController();
  final _yearController = TextEditingController();
  final _seatsController = TextEditingController(text: '4');
  
  bool _isLoading = false;

  @override
  void dispose() {
    _modelController.dispose();
    _licensePlateController.dispose();
    _yearController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Future<void> _handleAddVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    if (_brand == null || _color == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    try {
      final vehicle = Vehicle(
        id: '', // Sera généré par Firebase
        ownerId: userId,
        brand: _brand!,
        model: _modelController.text.trim(),
        color: _color!,
        year: int.parse(_yearController.text),
        licensePlate: _licensePlateController.text.trim(),
        seats: int.parse(_seatsController.text),
        imageUrl: null, // TODO: Ajouter upload d'image
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await context.read<VehicleProvider>().addVehicle(vehicle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Véhicule ajouté avec succès!'),
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
        title: const Text('Ajouter un véhicule'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car,
                  size: 50,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Brand
            const Text(
              'Marque',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _brand,
              decoration: InputDecoration(
                hintText: 'Sélectionner la marque',
                prefixIcon: const Icon(Icons.directions_car),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: AppConstants.vehicleBrands.map((brand) {
                return DropdownMenuItem(
                  value: brand,
                  child: Text(brand),
                );
              }).toList(),
              onChanged: (value) => setState(() => _brand = value),
              validator: (value) => value == null ? 'Marque requise' : null,
            ),
            const SizedBox(height: 16),

            // Model
            CustomTextField(
              controller: _modelController,
              label: 'Modèle',
              hint: '308, Clio, etc.',
              prefixIcon: Icons.category,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Modèle requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Color
            const Text(
              'Couleur',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _color,
              decoration: InputDecoration(
                hintText: 'Sélectionner la couleur',
                prefixIcon: const Icon(Icons.palette),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: AppConstants.vehicleColors.map((color) {
                return DropdownMenuItem(
                  value: color,
                  child: Text(color),
                );
              }).toList(),
              onChanged: (value) => setState(() => _color = value),
              validator: (value) => value == null ? 'Couleur requise' : null,
            ),
            const SizedBox(height: 16),

            // License Plate
            CustomTextField(
              controller: _licensePlateController,
              label: 'Plaque d\'immatriculation',
              hint: '123 TU 4567',
              prefixIcon: Icons.confirmation_number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Plaque requise';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Year
            DropdownButtonFormField<int>(
              value: _yearController.text.isNotEmpty ? int.tryParse(_yearController.text) : null,
              decoration: InputDecoration(
                labelText: 'Année *',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: List.generate(35, (index) => DateTime.now().year - index).map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _yearController.text = value.toString();
                }
              },
              validator: (value) {
                if (value == null || value < 1990 || value > DateTime.now().year + 1) {
                  return 'Année invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Seats
            DropdownButtonFormField<int>(
              value: _seatsController.text.isNotEmpty ? int.tryParse(_seatsController.text) : null,
              decoration: InputDecoration(
                labelText: 'Nombre de places *',
                prefixIcon: const Icon(Icons.event_seat),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: List.generate(8, (index) => index + 2).map((seats) {
                return DropdownMenuItem(
                  value: seats,
                  child: Text('$seats places'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _seatsController.text = value.toString();
                }
              },
              validator: (value) {
                if (value == null || value < 2 || value > 9) {
                  return 'Nombre de places invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Add Button
            Consumer<VehicleProvider>(
              builder: (context, vehicleProvider, _) {
                return CustomButton(
                  text: 'Ajouter le véhicule',
                  icon: Icons.check,
                  isLoading: vehicleProvider.isLoading,
                  onPressed: _handleAddVehicle,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
