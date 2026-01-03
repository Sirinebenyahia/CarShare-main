import 'package:flutter/material.dart';
import '../../models/ride.dart';
import '../../config/theme.dart';
import 'package:intl/intl.dart';
import '../../screens/rides/ride_chat_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../providers/ride_chat_provider.dart';
import '../../screens/rides/ride_discussions_screen.dart';
import '../../l10n/app_localizations.dart';

class RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback? onTap;
  final bool showDriverInfo;
  final VoidCallback? onMessageTap;

  const RideCard({
    Key? key,
    required this.ride,
    this.onTap,
    this.showDriverInfo = true,
    this.onMessageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Info
              if (showDriverInfo) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                      child: ride.driverImageUrl != null
                          ? null
                          : Text(
                              ride.driverName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.driverName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ride.driverRating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
              ],

              // Route
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.successGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.errorRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.fromCity,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          ride.toCity,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${ride.pricePerSeat.toStringAsFixed(2)} TND',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onMessageTap ??
                      () {
                        final auth = context.read<AuthProvider>();
                        final me = auth.currentUser;
                        if (me == null) return;

                        final isDriver = me.role == UserRole.driver || me.id == ride.driverId;
                        if (isDriver) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RideDiscussionsScreen(rideId: ride.id),
                            ),
                          );
                          return;
                        }

                        final passengerId = me.id;
                        final driverId = ride.driverId;
                        final chatId = context.read<RideChatProvider>().getChatId(
                              rideId: ride.id,
                              passengerId: passengerId,
                            );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RideChatScreen(
                              ride: ride,
                              chatId: chatId,
                              passengerId: passengerId,
                              driverId: driverId,
                            ),
                          ),
                        );
                      },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: Text(t.t('message')),
                ),
              ),

              // Intermediate stops
              if (ride.intermediateStops.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ride.intermediateStops.map((stop) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.lightBlue.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stop,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 16),

              // Details Row
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Icons.calendar_today,
                    label: DateFormat('dd MMM').format(ride.departureDate),
                  ),
                  _buildInfoChip(
                    icon: Icons.access_time,
                    label: ride.departureTime,
                  ),
                  _buildInfoChip(
                    icon: Icons.event_seat,
                    label: '${ride.availableSeats} place${ride.availableSeats > 1 ? 's' : ''}',
                  ),
                  if (ride.vehicle != null)
                    _buildInfoChip(
                      icon: Icons.directions_car,
                      label: '${ride.vehicle!.brand} ${ride.vehicle!.model}',
                    ),
                ],
              ),

              // Preferences (compact)
              if (_hasActivePreferences()) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (ride.preferences.smokingAllowed)
                      _buildPreferenceBadge(Icons.smoking_rooms, 'Fumeur'),
                    if (ride.preferences.petsAllowed)
                      _buildPreferenceBadge(Icons.pets, 'Animaux'),
                    if (ride.preferences.luggageAllowed)
                      _buildPreferenceBadge(Icons.luggage, 'Bagages'),
                    if (ride.preferences.musicAllowed)
                      _buildPreferenceBadge(Icons.music_note, 'Musique'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.greyText),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.successGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.successGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActivePreferences() {
    return ride.preferences.smokingAllowed ||
        ride.preferences.petsAllowed ||
        ride.preferences.luggageAllowed ||
        ride.preferences.musicAllowed;
  }
}
