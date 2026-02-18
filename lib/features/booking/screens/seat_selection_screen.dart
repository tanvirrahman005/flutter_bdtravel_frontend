import 'package:flutter/material.dart';
import 'package:bd_travel/core/constants/app_colors.dart';
import 'package:bd_travel/core/constants/app_routes.dart';
import 'package:bd_travel/data/models/schedule.dart';
import 'package:intl/intl.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Schedule schedule;

  const SeatSelectionScreen({
    super.key,
    required this.schedule,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final Set<String> _selectedSeats = {};
  final List<String> _bookedSeats = ['A1', 'A4', 'B2', 'C3']; // Demo booked seats

  @override
  Widget build(BuildContext context) {
    final totalAmount = _selectedSeats.length * widget.schedule.fare;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Seats'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Bus Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withOpacity(0.05),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_bus, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.schedule.companyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.schedule.fromCity} → ${widget.schedule.toCity}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM, hh:mm a').format(widget.schedule.departureTime),
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
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('Available', AppColors.success),
                const SizedBox(width: 24),
                _buildLegend('Selected', AppColors.primary),
                const SizedBox(width: 24),
                _buildLegend('Booked', AppColors.textSecondary),
              ],
            ),
          ),

          // Seat Layout
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Driver Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.drive_eta, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Seat Grid
                  ..._buildSeatRows(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Bar with Booking Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedSeats.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Seats',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedSeats.join(', '),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '৳${totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedSeats.isEmpty
                          ? null
                          : () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.bookingForm,
                                arguments: {
                                  'schedule': widget.schedule,
                                  'selectedSeats': _selectedSeats.toList(),
                                },
                              );
                            },
                      child: Text(
                        _selectedSeats.isEmpty
                            ? 'Select at least one seat'
                            : 'Continue (${_selectedSeats.length} seat${_selectedSeats.length > 1 ? "s" : ""})',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSeatRows() {
    final rows = <Widget>[];
    const columns = ['A', 'B', '', 'C', 'D'];
    const totalRows = 10;

    for (int row = 1; row <= totalRows; row++) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: columns.map((col) {
              if (col.isEmpty) {
                return const SizedBox(width: 48); // Aisle space
              }
              final seatNumber = '$col$row';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _buildSeat(seatNumber),
              );
            }).toList(),
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildSeat(String seatNumber) {
    final isBooked = _bookedSeats.contains(seatNumber);
    final isSelected = _selectedSeats.contains(seatNumber);

    Color seatColor;
    if (isBooked) {
      seatColor = AppColors.textSecondary;
    } else if (isSelected) {
      seatColor = AppColors.primary;
    } else {
      seatColor = AppColors.success;
    }

    return GestureDetector(
      onTap: isBooked
          ? null
          : () {
              setState(() {
                if (_selectedSeats.contains(seatNumber)) {
                  _selectedSeats.remove(seatNumber);
                } else {
                  _selectedSeats.add(seatNumber);
                }
              });
            },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: seatColor.withOpacity(0.1),
          border: Border.all(
            color: seatColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_seat,
                color: seatColor,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                seatNumber,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: seatColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
