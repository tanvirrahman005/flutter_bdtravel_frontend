import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/schedule_model.dart';
import 'package:bd_travel/data/models/vehicle_model.dart';
import 'package:bd_travel/data/models/route_model.dart';
import 'package:bd_travel/services/vehicle_service.dart';
import 'package:bd_travel/services/route_service.dart';
import 'package:bd_travel/services/schedule_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class ScheduleFormDialog extends StatefulWidget {
  final ScheduleModel? schedule;

  const ScheduleFormDialog({super.key, this.schedule});

  @override
  State<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<ScheduleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  
  final VehicleService _vehicleService = VehicleService();
  final RouteService _routeService = RouteService();
  final ScheduleService _scheduleService = ScheduleService();

  List<VehicleModel> _vehicles = [];
  List<RouteModel> _routes = [];
  
  VehicleModel? _selectedVehicle;
  RouteModel? _selectedRoute;
  DateTime? _departureDateTime;
  DateTime? _arrivalDateTime;
  String _status = 'SCHEDULED';

  bool _isLoadingData = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _priceController.text = widget.schedule!.basePrice.toString();
      _departureDateTime = widget.schedule!.departureTime;
      _arrivalDateTime = widget.schedule!.arrivalTime;
      _status = widget.schedule!.status;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final vehicles = await _vehicleService.getActiveVehicles();
      final routes = await _routeService.getAllRoutes(); // Assuming filtering is done if needed, or getActiveRoutes if available
      
      if (!mounted) return;
      setState(() {
        _vehicles = vehicles;
        _routes = routes.where((r) => r.isActive).toList();
        
        if (widget.schedule != null) {
          try {
            _selectedVehicle = _vehicles.firstWhere((v) => v.id == widget.schedule!.vehicle.id);
            _selectedRoute = _routes.firstWhere((r) => r.id == widget.schedule!.route.id);
          } catch (_) {}
        }
        _isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isDeparture) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: (isDeparture ? _departureDateTime : _arrivalDateTime) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime((isDeparture ? _departureDateTime : _arrivalDateTime) ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          final dateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isDeparture) {
            _departureDateTime = dateTime;
          } else {
            _arrivalDateTime = dateTime;
          }
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicle == null || _selectedRoute == null || _departureDateTime == null || _arrivalDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isSubmitting = true);

    final schedule = ScheduleModel(
      id: widget.schedule?.id ?? 0,
      vehicle: _selectedVehicle!,
      route: _selectedRoute!,
      departureTime: _departureDateTime!,
      arrivalTime: _arrivalDateTime!,
      basePrice: double.parse(_priceController.text),
      availableSeats: widget.schedule?.availableSeats ?? _selectedVehicle!.totalSeats,
      status: _status,
    );

    final result = widget.schedule != null
        ? await _scheduleService.updateSchedule(widget.schedule!.id, schedule)
        : await _scheduleService.createSchedule(schedule);

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: AppColors.success));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.schedule != null ? 'Edit Schedule' : 'Add Schedule'),
      content: _isLoadingData
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<VehicleModel>(
                      value: _selectedVehicle,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Vehicle *', border: OutlineInputBorder()),
                      items: _vehicles.map((v) => DropdownMenuItem(value: v, child: Text('${v.vehicleNumber} (${v.transportType.name})', overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _selectedVehicle = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<RouteModel>(
                      value: _selectedRoute,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Route *', border: OutlineInputBorder()),
                      items: _routes.map((r) => DropdownMenuItem(value: r, child: Text('${r.startCity.name} - ${r.endCity.name}', overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _selectedRoute = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _selectDateTime(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Departure Time *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.event)),
                        child: Text(_departureDateTime == null ? 'Select Date & Time' : DateFormat('MMM dd, yyyy - hh:mm a').format(_departureDateTime!)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _selectDateTime(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Arrival Time *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.event)),
                        child: Text(_arrivalDateTime == null ? 'Select Date & Time' : DateFormat('MMM dd, yyyy - hh:mm a').format(_arrivalDateTime!)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Base Price (TK) *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    if (widget.schedule != null) ...[
                       const SizedBox(height: 12),
                       DropdownButtonFormField<String>(
                         value: _status,
                         decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                         items: const [
                           DropdownMenuItem(value: 'SCHEDULED', child: Text('Scheduled')),
                           DropdownMenuItem(value: 'DEPARTED', child: Text('Departed')),
                           DropdownMenuItem(value: 'ARRIVED', child: Text('Arrived')),
                           DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
                         ],
                         onChanged: (v) => setState(() => _status = v!),
                       ),
                    ],
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(onPressed: _isSubmitting ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSubmitting || _isLoadingData ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: _isSubmitting 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(widget.schedule != null ? 'Update' : 'Create', style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
