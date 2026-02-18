import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/vehicle_model.dart';
import 'package:bd_travel/services/storage_service.dart';
import 'package:bd_travel/services/vehicle_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';
import 'package:bd_travel/features/admin/widgets/vehicle_form_dialog.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final VehicleService _vehicleService = VehicleService();
  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
    _loadVehicles();
  }

  Future<void> _checkAdminRole() async {
    final role = await StorageService.getRole();
    setState(() {
      _isAdmin = role == 'ADMIN';
    });
    
    if (!_isAdmin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access denied. Admin privileges required.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    try {
      final vehicles = await _vehicleService.getAllVehicles();
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading vehicles: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _showVehicleForm({VehicleModel? vehicle}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => VehicleFormDialog(vehicle: vehicle),
    );

    if (result == true) {
      _loadVehicles(); // Refresh list
    }
  }

  Future<void> _toggleVehicleStatus(VehicleModel vehicle) async {
    final action = vehicle.isActive ? 'deactivate' : 'activate';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action == 'activate' ? 'Activate' : 'Deactivate'} Vehicle'),
        content: Text(
          'Are you sure you want to $action ${vehicle.vehicleNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: vehicle.isActive ? Colors.orange : Colors.green,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              action == 'activate' ? 'Activate' : 'Deactivate',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final result = await _vehicleService.toggleVehicleStatus(vehicle.id, !vehicle.isActive);
      
      if (!mounted) return;
      Navigator.pop(context); // Hide loading

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        _loadVehicles(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteVehicle(VehicleModel vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
          'Are you sure you want to delete ${vehicle.vehicleNumber}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final result = await _vehicleService.deleteVehicle(vehicle.id);
      
      if (!mounted) return;
      Navigator.pop(context); // Hide loading

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        _loadVehicles(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadVehicles,
              child: _vehicles.isEmpty
                  ? const Center(
                      child: Text(
                        'No vehicles found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _vehicles.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final vehicle = _vehicles[index];
                        return _buildVehicleCard(vehicle);
                      },
                    ),
            ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => _showVehicleForm(),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: vehicle.isActive ? AppColors.primary : Colors.grey,
                  backgroundImage: (vehicle.transportCompany.logoUrl != null &&
                          vehicle.transportCompany.logoUrl!.isNotEmpty)
                      ? NetworkImage(vehicle.transportCompany.logoUrl!)
                      : null,
                  child: (vehicle.transportCompany.logoUrl == null ||
                          vehicle.transportCompany.logoUrl!.isEmpty)
                      ? const Icon(Icons.directions_bus, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.vehicleNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vehicle.transportCompany.name} • ${vehicle.transportType.name}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.airline_seat_recline_normal, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${vehicle.totalSeats} Seats',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.label, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            vehicle.vehicleType,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') _showVehicleForm(vehicle: vehicle);
                    if (value == 'toggle') _toggleVehicleStatus(vehicle);
                    if (value == 'delete') _deleteVehicle(vehicle);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            vehicle.isActive ? Icons.block : Icons.check_circle,
                            size: 20,
                            color: vehicle.isActive ? Colors.orange : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            vehicle.isActive ? 'Deactivate' : 'Activate',
                            style: TextStyle(
                              color: vehicle.isActive ? Colors.orange : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
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
                ),
              ],
            ),
            if (vehicle.model != null && vehicle.model!.isNotEmpty) ...[
              const Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Model: ${vehicle.model}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'ID: ${vehicle.id}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: vehicle.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: vehicle.isActive ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    vehicle.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: vehicle.isActive ? Colors.green : Colors.red,
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
  }
}
