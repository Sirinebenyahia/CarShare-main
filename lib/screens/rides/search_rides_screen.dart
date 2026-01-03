import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/ride/ride_card.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../l10n/app_localizations.dart';

class SearchRidesScreen extends StatefulWidget {
  const SearchRidesScreen({Key? key}) : super(key: key);

  @override
  State<SearchRidesScreen> createState() => _SearchRidesScreenState();
}

class _SearchRidesScreenState extends State<SearchRidesScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _fromCity;
  String? _toCity;
  DateTime? _selectedDate;
  double _maxPrice = 100.0;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    context.read<RideProvider>().fetchAllRides();
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
      setState(() => _selectedDate = picked);
    }
  }

  void _handleSearch() {
    context.read<RideProvider>().searchRides(
          fromCity: _fromCity,
          toCity: _toCity,
          date: _selectedDate,
          maxPrice: _maxPrice,
        );
  }

  void _clearFilters() {
    setState(() {
      _fromCity = null;
      _toCity = null;
      _selectedDate = null;
      _maxPrice = 100.0;
    });
    context.read<RideProvider>().clearSearchResults();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('search_ride')),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // From City
                  DropdownButtonFormField<String>(
                    value: _fromCity,
                    decoration: InputDecoration(
                      labelText: t.t('departure'),
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
                    onChanged: (value) {
                      setState(() => _fromCity = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // To City
                  DropdownButtonFormField<String>(
                    value: _toCity,
                    decoration: InputDecoration(
                      labelText: t.t('destination'),
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
                    onChanged: (value) {
                      setState(() => _toCity = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: AppTheme.greyText),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate == null
                                ? t.t('choose_date')
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedDate == null
                                  ? Colors.grey[400]
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Advanced Filters
                  if (_showFilters) ...[
                    const SizedBox(height: 16),
                    _buildAdvancedFilters(),
                  ],

                  const SizedBox(height: 20),

                  // Search Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: t.t('search'),
                          icon: Icons.search,
                          onPressed: _handleSearch,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _clearFilters,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Icon(Icons.clear),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Results
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${t.t('max_price')}: ${_maxPrice.toStringAsFixed(0)} TND',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Slider(
          value: _maxPrice,
          min: 0,
          max: 200,
          divisions: 20,
          activeColor: AppTheme.primaryBlue,
          label: '${_maxPrice.toStringAsFixed(0)} TND',
          onChanged: (value) {
            setState(() => _maxPrice = value);
          },
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Consumer<RideProvider>(
      builder: (context, rideProvider, _) {
        final t = AppLocalizations.of(context);
        if (rideProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final rides = rideProvider.searchResults.isEmpty
            ? rideProvider.allRides
            : rideProvider.searchResults;

        if (rides.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  t.t('no_rides_found'),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Essayez de modifier vos critères',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rides.length,
          itemBuilder: (context, index) {
            return RideCard(
              ride: rides[index],
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/ride-details',
                  arguments: rides[index],
                );
              },
            );
          },
        );
      },
    );
  }
}
