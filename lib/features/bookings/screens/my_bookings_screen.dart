import 'package:flutter/material.dart';
import 'package:bd_travel/core/constants/app_colors.dart';
import 'package:bd_travel/data/local/database_helper.dart';
import 'package:bd_travel/data/models/booking.dart';
import 'package:bd_travel/shared/widgets/app_drawer.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    
    // Create demo bookings if none exist
    final bookings = await _dbHelper.getAllBookings();
    if (bookings.isEmpty) {
      await _createDemoBookings();
    }
    
    final loadedBookings = await _dbHelper.getAllBookings();
    setState(() {
      _bookings = loadedBookings;
      _isLoading = false;
    });
  }

  Future<void> _createDemoBookings() async {
    final demoBookings = [
      Booking(
        bookingReference: 'BT${DateTime.now().millisecondsSinceEpoch}',
        scheduleId: 1,
        passengerName: 'John Doe',
        passengerPhone: '+8801712345678',
        passengerEmail: 'john@example.com',
        totalAmount: 1600.0,
        bookingStatus: 'CONFIRMED',
        bookingDate: DateTime.now().subtract(const Duration(days: 2)),
        fromCity: 'Dhaka',
        toCity: 'Chittagong',
        journeyDate: DateTime.now().add(const Duration(days: 3)),
        seatNumbers: ['A1', 'A2'],
      ),
      Booking(
        bookingReference: 'BT${DateTime.now().millisecondsSinceEpoch + 1}',
        scheduleId: 2,
        passengerName: 'Jane Smith',
        passengerPhone: '+8801812345679',
        passengerEmail: 'jane@example.com',
        totalAmount: 600.0,
        bookingStatus: 'PENDING',
        bookingDate: DateTime.now().subtract(const Duration(hours: 5)),
        fromCity: 'Dhaka',
        toCity: 'Sylhet',
        journeyDate: DateTime.now().add(const Duration(days: 1)),
        seatNumbers: ['B3'],
      ),
    ];

    for (var booking in demoBookings) {
      await _dbHelper.createBooking(booking);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      return _buildBookingCard(_bookings[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Bookings Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Your booking history will appear here',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Book a Ticket'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final statusColor = booking.bookingStatus == 'CONFIRMED'
        ? AppColors.success
        : booking.bookingStatus == 'CANCELLED'
            ? AppColors.error
            : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.confirmation_number, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  booking.bookingReference,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.bookingStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Route Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.fromCity,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM, hh:mm a').format(booking.journeyDate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: AppColors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            booking.toCity,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Arrival',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Booking Details
                Row(
                  children: [
                    _buildInfoItem(Icons.person, 'Passenger', booking.passengerName),
                    const SizedBox(width: 16),
                    _buildInfoItem(Icons.event_seat, 'Seats', booking.seatNumbers.join(', ')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoItem(Icons.phone, 'Phone', booking.passengerPhone),
                    const SizedBox(width: 16),
                    _buildInfoItem(Icons.attach_money, 'Amount', '৳${booking.totalAmount.toStringAsFixed(0)}'),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Download ticket - Coming Soon'),
                              backgroundColor: AppColors.info,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        child: const Text('Download'),
                      ),
                    ),
                    if (booking.bookingStatus == 'CONFIRMED') ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _cancelBooking(booking),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dbHelper.updateBookingStatus(booking.id!, 'CANCELLED');
              Navigator.pop(context);
              _loadBookings();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancelled successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
