import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/ride.dart';
import '../../providers/booking_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../config/theme.dart';

class RideDetailsScreen extends StatefulWidget {
  final Ride ride;

  const RideDetailsScreen({
    Key? key,
    required this.ride,
  }) : super(key: key);

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  int _selectedSeats = 1;

  void _showBookingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildBookingModal(),
    );
  }

  Widget _buildBookingModal() {
    final totalPrice = widget.ride.pricePerSeat * _selectedSeats;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Réserver ce trajet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Seats Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nombre de places',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _selectedSeats > 1
                          ? () => setState(() => _selectedSeats--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppTheme.primaryBlue,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_selectedSeats',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _selectedSeats < widget.ride.availableSeats
                          ? () => setState(() => _selectedSeats++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppTheme.primaryBlue,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),

            // Price Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prix par place',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '${widget.ride.pricePerSeat.toStringAsFixed(2)} TND',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total ($_selectedSeats place${_selectedSeats > 1 ? 's' : ''})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${totalPrice.toStringAsFixed(2)} TND',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Wallet Balance
            Consumer<WalletProvider>(
              builder: (context, walletProvider, _) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Solde du portefeuille'),
                      Text(
                        '${walletProvider.balance.toStringAsFixed(2)} TND',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: walletProvider.balance >= totalPrice
                              ? AppTheme.successGreen
                              : AppTheme.errorRed,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Book Button
            Consumer2<BookingProvider, WalletProvider>(
              builder: (context, bookingProvider, walletProvider, _) {
                final canBook = walletProvider.balance >= totalPrice;

                return CustomButton(
                  text: canBook ? 'Confirmer la réservation' : 'Recharger le portefeuille',
                  icon: canBook ? Icons.check : Icons.account_balance_wallet,
                  isLoading: bookingProvider.isLoading,
                  onPressed: () async {
                    if (!canBook) {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/wallet');
                      return;
                    }

                    final user = context.read<AuthProvider>().currentUser!;

                    try {
                      await bookingProvider.createBooking(
                        rideId: widget.ride.id,
                        passengerId: user.id,
                        passengerName: user.fullName,
                        passengerImageUrl: user.profileImageUrl,
                        driverId: widget.ride.driverId,
                        seatsBooked: _selectedSeats,
                        totalPrice: totalPrice,
                      );

                      await walletProvider.makePayment(
                        amount: totalPrice,
                        description: 'Réservation trajet ${widget.ride.fromCity} - ${widget.ride.toCity}',
                        relatedId: widget.ride.id,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Réservation confirmée!'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: ${e.toString()}'),
                            backgroundColor: AppTheme.errorRed,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du trajet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share ride
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Driver Info
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    child: widget.ride.vehicleInfo?['driverInfo']?['avatar'] != null
                        ? null
                        : Text(
                            widget.ride.vehicleInfo?['driverInfo']?['name']?.substring(0, 1).toUpperCase() ?? 'D',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ride.vehicleInfo?['driverInfo']?['name'] ?? 'Conducteur',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              (widget.ride.vehicleInfo?['driverInfo']?['rating'] ?? 0.0).toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if ((widget.ride.vehicleInfo?['driverInfo']?['rating'] ?? 0.0) >= 4.5)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Excellent',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.successGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.message_outlined),
                    onPressed: () {
                      // TODO: Message driver
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Route Details
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppTheme.successGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 60,
                            color: Colors.grey[300],
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppTheme.errorRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.ride.fromCity,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 50),
                            Text(
                              widget.ride.toCity,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Intermediate stops are not supported in current model
                  // if (widget.ride.intermediateStops.isNotEmpty) ...[
                  //   const SizedBox(height: 12),
                  //   Wrap(
                  //     spacing: 8,
                  //     runSpacing: 8,
                  //     children: widget.ride.intermediateStops.map((stop) {
                  //       return Chip(
                  //         label: Text(stop),
                  //         avatar: const Icon(Icons.location_on, size: 16),
                  //       );
                  //     }).toList(),
                  //   ),
                  // ],
                ],
              ),
            ),

            const Divider(height: 1),

            // Trip Info
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date',
                    '${widget.ride.departureDate.day}/${widget.ride.departureDate.month}/${widget.ride.departureDate.year}',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.access_time,
                    'Heure',
                    DateFormat('HH:mm', 'fr_FR').format(widget.ride.departureDate),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.event_seat,
                    'Places disponibles',
                    '${widget.ride.availableSeats}',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.attach_money,
                    'Prix par place',
                    '${widget.ride.pricePerSeat.toStringAsFixed(2)} TND',
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Vehicle Info
            if (widget.ride.vehicleInfo != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Véhicule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.ride.vehicleInfo!['brand'] ?? 'N/A'} ${widget.ride.vehicleInfo!['model'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${widget.ride.vehicleInfo!['color'] ?? 'N/A'} • ${widget.ride.vehicleInfo!['year'] ?? 'N/A'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
            ],

            // Preferences
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Préférences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildPreferenceChip(
                        'Fumeur',
                        widget.ride.preferences?.smokingAllowed ?? false,
                        Icons.smoking_rooms,
                      ),
                      _buildPreferenceChip(
                        'Animaux',
                        widget.ride.preferences?.petsAllowed ?? false,
                        Icons.pets,
                      ),
                      _buildPreferenceChip(
                        'Bagages',
                        widget.ride.preferences?.luggageAllowed ?? false,
                        Icons.luggage,
                      ),
                      _buildPreferenceChip(
                        'Musique',
                        widget.ride.preferences?.musicAllowed ?? false,
                        Icons.music_note,
                      ),
                      _buildPreferenceChip(
                        'Discussion',
                        widget.ride.preferences?.chattingAllowed ?? false,
                        Icons.chat,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            text: 'Réserver (${widget.ride.pricePerSeat.toStringAsFixed(2)} TND)',
            icon: Icons.book_online,
            onPressed: _showBookingModal,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.greyText),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceChip(String label, bool allowed, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: allowed
            ? AppTheme.successGreen.withOpacity(0.1)
            : AppTheme.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: allowed
              ? AppTheme.successGreen.withOpacity(0.3)
              : AppTheme.errorRed.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            allowed ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: allowed ? AppTheme.successGreen : AppTheme.errorRed,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: allowed ? AppTheme.successGreen : AppTheme.errorRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
