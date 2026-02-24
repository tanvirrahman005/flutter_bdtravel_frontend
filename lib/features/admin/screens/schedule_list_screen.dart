import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/schedule_model.dart';
import 'package:bd_travel/services/schedule_service.dart';
import 'package:bd_travel/services/auth_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';
import 'package:bd_travel/features/admin/widgets/schedule_form_dialog.dart';
import 'package:intl/intl.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();
  
  List<ScheduleModel> _schedules = [];
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
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final schedules = await _scheduleService.getAllSchedules();
      setState(() {
        _schedules = schedules;
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
      case 'SCHEDULED': return Colors.blue;
      case 'DEPARTED': return Colors.orange;
      case 'ARRIVED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _updateStatus(ScheduleModel schedule, String status) async {
    final result = await _scheduleService.updateScheduleStatus(schedule.id, status);
    if (result['success']) {
       _loadSchedules();
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: AppColors.success));
    } else {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: AppColors.error));
    }
  }

  Future<void> _deleteSchedule(ScheduleModel schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _scheduleService.deleteSchedule(schedule.id);
      if (result['success']) {
        _loadSchedules();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: AppColors.success));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? const Center(child: Text('No schedules found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = _schedules[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _getStatusColor(schedule.status).withOpacity(0.1),
                                  child: Icon(Icons.schedule, color: _getStatusColor(schedule.status)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${schedule.route.startCity.name} ➔ ${schedule.route.endCity.name}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        'Vehicle: ${schedule.vehicle.vehicleNumber}',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isAdminOrOperator)
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        showDialog(context: context, builder: (context) => ScheduleFormDialog(schedule: schedule)).then((v) { if (v == true) _loadSchedules(); });
                                      } else if (value == 'delete') {
                                        _deleteSchedule(schedule);
                                      } else {
                                        _updateStatus(schedule, value);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')])),
                                      const PopupMenuItem(value: 'SCHEDULED', child: Row(children: [Icon(Icons.timer, size: 20, color: Colors.blue), SizedBox(width: 8), Text('Set Scheduled')])),
                                      const PopupMenuItem(value: 'DEPARTED', child: Row(children: [Icon(Icons.launch, size: 20, color: Colors.orange), SizedBox(width: 8), Text('Set Departed')])),
                                      const PopupMenuItem(value: 'ARRIVED', child: Row(children: [Icon(Icons.check_circle, size: 20, color: Colors.green), SizedBox(width: 8), Text('Set Arrived')])),
                                      const PopupMenuItem(value: 'CANCELLED', child: Row(children: [Icon(Icons.cancel, size: 20, color: Colors.red), SizedBox(width: 8), Text('Set Cancelled')])),
                                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Delete')])),
                                    ],
                                  ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Departure', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text(DateFormat('MMM dd, hh:mm a').format(schedule.departureTime), style: const TextStyle(fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Arrival', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text(DateFormat('MMM dd, hh:mm a').format(schedule.arrivalTime), style: const TextStyle(fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(schedule.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _getStatusColor(schedule.status)),
                                  ),
                                  child: Text(
                                    schedule.status,
                                    style: TextStyle(color: _getStatusColor(schedule.status), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Price: ${schedule.basePrice} TK',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: _isAdminOrOperator
          ? FloatingActionButton(
              onPressed: () => showDialog(context: context, builder: (context) => const ScheduleFormDialog()).then((v) { if (v == true) _loadSchedules(); }),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
