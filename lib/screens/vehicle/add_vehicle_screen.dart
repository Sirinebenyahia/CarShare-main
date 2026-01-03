import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vehicle.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../l10n/app_localizations.dart';

class AddVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AddVehicleScreen({Key? key, this.vehicle}) : super(key: key);

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

  @override
  void initState() {
    super.initState();

    final v = widget.vehicle;
    if (v != null) {
      _brand = v.brand;
      _modelController.text = v.model;
      _color = v.color;
      _licensePlateController.text = v.licensePlate;
      _yearController.text = v.year.toString();
      _seatsController.text = v.seats.toString();
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _licensePlateController.dispose();
    _yearController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Future<void> _handleAddVehicle() async {
    final t = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    if (_brand == null || _color == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.t('vehicle_required')),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    try {
      final existing = widget.vehicle;

      if (existing == null) {
        await context.read<VehicleProvider>().addVehicle(
              ownerId: userId,
              brand: _brand!,
              model: _modelController.text.trim(),
              color: _color!,
              licensePlate: _licensePlateController.text.trim(),
              year: int.parse(_yearController.text),
              seats: int.parse(_seatsController.text),
            );
      } else {
        final updated = existing.copyWith(
          ownerId: existing.ownerId,
          brand: _brand!,
          model: _modelController.text.trim(),
          color: _color!,
          licensePlate: _licensePlateController.text.trim(),
          year: int.parse(_yearController.text),
          seats: int.parse(_seatsController.text),
        );
        await context.read<VehicleProvider>().updateVehicle(existing.id, updated);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(existing == null ? t.t('vehicle_added') : 'Véhicule modifié avec succès!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.t('error')}: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isEditing = widget.vehicle != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? t.t('edit_profile_title') : t.t('add_vehicle')),
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
            Text(
              t.t('brand'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _brand,
              decoration: InputDecoration(
                labelText: t.t('brand'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: AppConstants.carBrands.map((brand) {
                return DropdownMenuItem(
                  value: brand,
                  child: Text(brand),
                );
              }).toList(),
              onChanged: (value) => setState(() => _brand = value),
              validator: (value) => value == null ? t.t('brand_required') : null,
            ),
            const SizedBox(height: 16),

            // Model
            CustomTextField(
              controller: _modelController,
              label: t.t('model'),
              hint: '308, Clio, etc.',
              prefixIcon: Icons.category,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.t('model_required');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Color
            Text(
              t.t('color'),
              style: const TextStyle(
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
              validator: (value) => value == null ? t.t('color_required') : null,
            ),
            const SizedBox(height: 16),

            // License Plate
            CustomTextField(
              controller: _licensePlateController,
              label: t.t('license_plate'),
              hint: '123 TU 4567',
              prefixIcon: Icons.confirmation_number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.t('license_plate_required');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Year
            CustomTextField(
              controller: _yearController,
              label: t.t('year'),
              hint: '2020',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.calendar_today,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.t('year_required');
                }
                final year = int.tryParse(value);
                if (year == null || year < 1990 || year > DateTime.now().year + 1) {
                  return 'Année invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Seats
            CustomTextField(
              controller: _seatsController,
              label: t.t('seats'),
              keyboardType: TextInputType.number,
              prefixIcon: Icons.event_seat,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.t('seats_required');
                }
                final seats = int.tryParse(value);
                if (seats == null || seats < 2 || seats > 9) {
                  return 'Entre 2 et 9 places';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Add Button
            Consumer<VehicleProvider>(
              builder: (context, vehicleProvider, _) {
                return CustomButton(
                  text: isEditing ? t.t('save') : t.t('add_vehicle'),
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
