import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/seat_layout_model.dart';
import 'package:bd_travel/data/models/vehicle_model.dart';
import 'package:bd_travel/services/storage_service.dart';
import 'package:bd_travel/services/seat_layout_service.dart';
import 'package:bd_travel/services/vehicle_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';
import 'package:bd_travel/features/admin/widgets/seat_layout_form_dialog.dart';

class SeatLayoutListScreen extends StatefulWidget {
  const SeatLayoutListScreen({super.key});

  @override
  State<SeatLayoutListScreen> createState() => _SeatLayoutListScreenState();
}

class _SeatLayoutListScreenState extends State<SeatLayoutListScreen> {
  final SeatLayoutService _seatService = SeatLayoutService();
  final VehicleService _vehicleService = VehicleService();
  
  List<SeatLayoutModel> _seats = [];
  List<VehicleModel> _vehicles = [];
  VehicleModel? _selectedVehicle;
  
  bool _isLoading = true;
  bool _isAdminOrOperator = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
    _loadInitialData();
  }

  Future<void> _checkRole() async {
    final role = await StorageService.getRole();
    setState(() {
      _isAdminOrOperator = role == 'ADMIN' || role == 'OPERATOR';
    });
    
    if (!_isAdminOrOperator) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access denied. Admin or Operator privileges required.')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final vehicles = await _vehicleService.getAllVehicles();
      setState(() {
        _vehicles = vehicles;
        if (_vehicles.isNotEmpty) {
          _selectedVehicle = _vehicles.first;
        }
      });
      if (_selectedVehicle != null) {
        await _loadSeats();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _loadSeats() async {
    if (_selectedVehicle == null) return;
    setState(() => _isLoading = true);
    try {
      final seats = await _seatService.getSeatsByVehicle(_selectedVehicle!.id);
      setState(() {
        _seats = seats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading seats: $e')));
      }
    }
  }

  Future<void> _toggleAvailability(SeatLayoutModel seat) async {
    final result = await _seatService.toggleSeatAvailability(seat.id, !seat.isAvailable);
    if (result['success']) {
      _loadSeats();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  Future<void> _deleteSeat(SeatLayoutModel seat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Seat'),
        content: Text('Are you sure you want to delete seat ${seat.seatNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _seatService.deleteSeat(seat.id);
      if (result['success']) {
        _loadSeats();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seat Layouts'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<VehicleModel>(
              value: _selectedVehicle,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Filter by Vehicle',
                border: OutlineInputBorder(),
              ),
              items: _vehicles.map((v) {
                return DropdownMenuItem(
                  value: v,
                  child: Text(
                    '${v.vehicleNumber} (${v.transportCompany.name})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedVehicle = value);
                _loadSeats();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadSeats,
                    child: _seats.isEmpty
                        ? const Center(child: Text('No seats found for this vehicle'))
                        : ListView.builder(
                            itemCount: _seats.length,
                            itemBuilder: (context, index) {
                              final seat = _seats[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          backgroundColor: seat.isAvailable ? Colors.green : Colors.red,
                                          child: const Icon(Icons.event_seat, color: Colors.white),
                                        ),
                                        title: Text('Seat: ${seat.seatNumber}'),
                                        subtitle: Text('Type: ${seat.seatType} | Deck: ${seat.deckLevel}'),
                                        trailing: _isAdminOrOperator 
                                          ? PopupMenuButton<String>(
                                              onSelected: (value) {
                                                if (value == 'edit') {
                                                  showDialog(context: context, builder: (context) => SeatLayoutFormDialog(seat: seat)).then((value) { if (value == true) _loadSeats(); });
                                                } else if (value == 'toggle') {
                                                  _toggleAvailability(seat);
                                                } else if (value == 'delete') {
                                                  _deleteSeat(seat);
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'edit', 
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.edit, size: 20),
                                                      SizedBox(width: 8),
                                                      Text('Edit'),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 'toggle', 
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        seat.isAvailable ? Icons.block : Icons.check_circle, 
                                                        size: 20, 
                                                        color: seat.isAvailable ? Colors.orange : Colors.green
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        seat.isAvailable ? 'Deactivate' : 'Activate',
                                                        style: TextStyle(color: seat.isAvailable ? Colors.orange : Colors.green),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete', 
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                                      SizedBox(width: 8),
                                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : null,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            'ID: ${seat.id}',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: seat.isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: seat.isAvailable ? Colors.green : Colors.red,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              seat.isAvailable ? 'Active' : 'Inactive',
                                              style: TextStyle(
                                                color: seat.isAvailable ? Colors.green : Colors.red,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                  ),
          ),
        ],
      ),
      floatingActionButton: _isAdminOrOperator
          ? FloatingActionButton(
              onPressed: () => showDialog(context: context, builder: (context) => SeatLayoutFormDialog(initialVehicle: _selectedVehicle)).then((value) { if (value == true) _loadSeats(); }),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
