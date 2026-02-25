import 'package:flutter/material.dart';
import 'package:bd_travel/core/constants/app_colors.dart';
import 'package:bd_travel/core/constants/app_routes.dart';
import 'package:bd_travel/data/models/schedule_model.dart';
import 'package:bd_travel/services/seat_layout_service.dart';
import 'package:bd_travel/data/models/seat_layout_model.dart';
import 'package:intl/intl.dart';

class SeatSelectionScreen extends StatefulWidget {
  final ScheduleModel schedule;

  const SeatSelectionScreen({
    super.key,
    required this.schedule,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final SeatLayoutService _seatLayoutService = SeatLayoutService();
  final Set<SeatLayoutModel> _selectedSeats = {};
  List<SeatLayoutModel> _allSeats = [];
  List<String> _bookedSeatNumbers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _seatLayoutService.getSeatsByVehicle(widget.schedule.vehicle.id),
        _seatLayoutService.getBookedSeatsBySchedule(widget.schedule.id),
      ]);

      setState(() {
        _allSeats = results[0] as List<SeatLayoutModel>;
        _bookedSeatNumbers = (results[1] as List<SeatLayoutModel>)
            .map((s) => s.seatNumber)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load seats: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _selectedSeats.length * widget.schedule.basePrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Seats'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
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
                                  widget.schedule.vehicle.transportCompany.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.schedule.route.startCity.name} → ${widget.schedule.route.endCity.name}',
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
                                        _selectedSeats.map((s) => s.seatNumber).join(', '),
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
                                            'selectedSeats': List<SeatLayoutModel>.from(_selectedSeats),
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
    if (_allSeats.isEmpty) return [];

    // Filter by deck level (LOWER is default for now)
    final lowerSeats = _allSeats.where((s) => s.deckLevel == 'LOWER').toList();

    // Group by row
    final Map<int, List<SeatLayoutModel>> rowsMap = {};
    for (var seat in lowerSeats) {
      final row = seat.rowPosition ?? 0;
      rowsMap.putIfAbsent(row, () => []).add(seat);
    }

    final sortedRows = rowsMap.keys.toList()..sort();

    return sortedRows.map((rowNum) {
      final seatsInRow = rowsMap[rowNum]!;
      seatsInRow.sort((a, b) => (a.columnPosition ?? 0).compareTo(b.columnPosition ?? 0));

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildRowSeats(seatsInRow),
        ),
      );
    }).toList();
  }

  List<Widget> _buildRowSeats(List<SeatLayoutModel> seats) {
    final widgets = <Widget>[];
    for (int i = 0; i < seats.length; i++) {
      final seat = seats[i];

      if (i > 0) {
        final prevCol = seats[i - 1].columnPosition ?? 0;
        final currentCol = seat.columnPosition ?? 0;
        // If there's a gap in column positions or it's the middle of a 2+2 row
        if (currentCol - prevCol > 1 || (i == 2 && seats.length >= 4)) {
          widgets.add(const SizedBox(width: 48));
        }
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _buildSeat(seat),
        ),
      );
    }
    return widgets;
  }

  Widget _buildSeat(SeatLayoutModel seat) {
    final isBooked = _bookedSeatNumbers.contains(seat.seatNumber);
    final isSelected = _selectedSeats.any((s) => s.id == seat.id);

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
                if (_selectedSeats.any((s) => s.id == seat.id)) {
                  _selectedSeats.removeWhere((s) => s.id == seat.id);
                } else {
                  _selectedSeats.add(seat);
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
                seat.seatNumber,
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
