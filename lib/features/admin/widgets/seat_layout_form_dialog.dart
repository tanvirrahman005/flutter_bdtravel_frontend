import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/seat_layout_model.dart';
import 'package:bd_travel/data/models/vehicle_model.dart';
import 'package:bd_travel/services/vehicle_service.dart';
import 'package:bd_travel/services/seat_layout_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';

class SeatLayoutFormDialog extends StatefulWidget {
  final SeatLayoutModel? seat;
  final VehicleModel? initialVehicle;

  const SeatLayoutFormDialog({super.key, this.seat, this.initialVehicle});

  @override
  State<SeatLayoutFormDialog> createState() => _SeatLayoutFormDialogState();
}

class _SeatLayoutFormDialogState extends State<SeatLayoutFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _seatNumberController = TextEditingController();
  final _rowController = TextEditingController();
  final _columnController = TextEditingController();
  
  final VehicleService _vehicleService = VehicleService();
  final SeatLayoutService _seatService = SeatLayoutService();

  bool _isLoading = false;
  bool _isLoadingData = true;
  
  List<VehicleModel> _vehicles = [];
  VehicleModel? _selectedVehicle;
  String _selectedSeatType = 'REGULAR';
  String _selectedDeckLevel = 'LOWER';

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      final vehicles = await _vehicleService.getActiveVehicles();

      if (!mounted) return;

      setState(() {
        _vehicles = vehicles;
        _isLoadingData = false;
      });

      if (widget.seat != null) {
        _seatNumberController.text = widget.seat!.seatNumber;
        _rowController.text = widget.seat!.rowPosition?.toString() ?? '';
        _columnController.text = widget.seat!.columnPosition?.toString() ?? '';
        _selectedSeatType = widget.seat!.seatType;
        _selectedDeckLevel = widget.seat!.deckLevel;
        
        try {
          _selectedVehicle = _vehicles.firstWhere((v) => v.id == widget.seat!.vehicle.id);
        } catch (_) {}
      } else if (widget.initialVehicle != null) {
        try {
          _selectedVehicle = _vehicles.firstWhere((v) => v.id == widget.initialVehicle!.id);
        } catch (_) {}
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading vehicles: $e')),
      );
    }
  }

  @override
  void dispose() {
    _seatNumberController.dispose();
    _rowController.dispose();
    _columnController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final seat = SeatLayoutModel(
      id: widget.seat?.id ?? 0,
      vehicle: _selectedVehicle!,
      seatNumber: _seatNumberController.text.trim(),
      seatType: _selectedSeatType,
      deckLevel: _selectedDeckLevel,
      rowPosition: int.tryParse(_rowController.text.trim()),
      columnPosition: int.tryParse(_columnController.text.trim()),
      isAvailable: widget.seat?.isAvailable ?? true,
    );

    Map<String, dynamic> result;
    if (widget.seat != null) {
      result = await _seatService.updateSeat(widget.seat!.id, seat);
    } else {
      result = await _seatService.createSeat(seat);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: AppColors.success),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.seat != null ? 'Edit Seat' : 'Add Seat'),
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
                      decoration: const InputDecoration(
                        labelText: 'Vehicle *',
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
                      onChanged: (value) => setState(() => _selectedVehicle = value),
                      validator: (value) => value == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _seatNumberController,
                      decoration: const InputDecoration(labelText: 'Seat Number *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.event_seat)),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedSeatType,
                      decoration: const InputDecoration(labelText: 'Seat Type', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'REGULAR', child: Text('Regular')),
                        DropdownMenuItem(value: 'PREMIUM', child: Text('Premium')),
                        DropdownMenuItem(value: 'BUSINESS', child: Text('Business')),
                      ],
                      onChanged: (value) => setState(() => _selectedSeatType = value!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedDeckLevel,
                      decoration: const InputDecoration(labelText: 'Deck Level', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'LOWER', child: Text('Lower')),
                        DropdownMenuItem(value: 'UPPER', child: Text('Upper')),
                      ],
                      onChanged: (value) => setState(() => _selectedDeckLevel = value!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _rowController,
                            decoration: const InputDecoration(labelText: 'Row', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _columnController,
                            decoration: const InputDecoration(labelText: 'Column', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(onPressed: _isLoading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading || _isLoadingData ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : Text(widget.seat != null ? 'Update' : 'Create', style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
