import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      await context.read<BookingProvider>().fetchMyBookings(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('my_bookings')),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookingProvider.myBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_online,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.t('no_bookings'),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.t('no_bookings_subtitle'),
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
            itemCount: bookingProvider.myBookings.length,
            itemBuilder: (context, index) {
              final booking = bookingProvider.myBookings[index];
              return _buildBookingCard(booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.directions_car,
            color: AppTheme.primaryBlue,
          ),
        ),
        title: Text(
          booking.rideTitle ?? 'Trajet',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${booking.departure} → ${booking.destination}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          '${booking.price?.toStringAsFixed(2) ?? '0'} TND',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        onTap: () {
          // TODO: Navigate to booking details
        },
      ),
    );
  }
}
