import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/booking.dart';
import 'package:bd_travel/services/booking_admin_service.dart';
import 'package:bd_travel/services/auth_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final BookingAdminService _bookingService = BookingAdminService();
  final AuthService _authService = AuthService();
  
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String _role = 'USER';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final userData = await _authService.getCurrentUser();
    setState(() => _role = userData['role'] ?? 'USER');
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await _bookingService.getAllBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  bool get _isAdminOrOperator => _role == 'ADMIN' || _role == 'OPERATOR';

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING': return Colors.orange;
      case 'CONFIRMED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _updateStatus(Booking booking, String status) async {
    final result = await _bookingService.updateBookingStatus(booking.id!, status);
    if (result['success']) {
       _loadBookings();
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: AppColors.success));
    } else {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: AppColors.error));
    }
  }

  Future<void> _deleteBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this booking entirely?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _bookingService.deleteBooking(booking.id!);
      if (result['success']) {
        _loadBookings();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: AppColors.success));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No bookings found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ref: ${booking.bookingReference}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(booking.bookingStatus).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _getStatusColor(booking.bookingStatus)),
                                  ),
                                  child: Text(
                                    booking.bookingStatus,
                                    style: TextStyle(color: _getStatusColor(booking.bookingStatus), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Text('Passenger: ${booking.passengerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Phone: ${booking.passengerPhone}'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.directions_bus, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(child: Text('${booking.fromCity} ➔ ${booking.toCity}', style: const TextStyle(fontSize: 14))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(DateFormat('MMM dd, yyyy').format(booking.journeyDate)),
                                const Spacer(),
                                const Icon(Icons.event_seat, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('Seats: ${booking.seatNumbers.join(", ")}'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total: ${booking.totalAmount} TK',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                if (_isAdminOrOperator)
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _deleteBooking(booking);
                                      } else {
                                        _updateStatus(booking, value);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'PENDING', child: Row(children: [Icon(Icons.timer, size: 20, color: Colors.orange), SizedBox(width: 8), Text('Set Pending')])),
                                      const PopupMenuItem(value: 'CONFIRMED', child: Row(children: [Icon(Icons.check_circle, size: 20, color: Colors.green), SizedBox(width: 8), Text('Set Confirmed')])),
                                      const PopupMenuItem(value: 'CANCELLED', child: Row(children: [Icon(Icons.cancel, size: 20, color: Colors.red), SizedBox(width: 8), Text('Set Cancelled')])),
                                      const PopupMenuDivider(),
                                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Delete')])),
                                    ],
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('Actions', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
