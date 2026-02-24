import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/route_model.dart';
import 'package:bd_travel/data/models/city_model.dart';
import 'package:bd_travel/data/models/transport_type_model.dart';
import 'package:bd_travel/services/city_service.dart';
import 'package:bd_travel/services/transport_type_service.dart';
import 'package:bd_travel/services/route_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';

class RouteFormDialog extends StatefulWidget {
  final RouteModel? route;

  const RouteFormDialog({super.key, this.route});

  @override
  State<RouteFormDialog> createState() => _RouteFormDialogState();
}

class _RouteFormDialogState extends State<RouteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _routeNumberController = TextEditingController();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();

  final CityService _cityService = CityService();
  final TransportTypeService _typeService = TransportTypeService();
  final RouteService _routeService = RouteService();

  List<CityModel> _cities = [];
  List<TransportTypeModel> _types = [];
  
  CityModel? _startCity;
  CityModel? _endCity;
  TransportTypeModel? _transportType;

  bool _isLoadingData = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final cities = await _cityService.getActiveCities();
      final types = await _typeService.getAllTransportTypes();

      if (!mounted) return;

      setState(() {
        _cities = cities;
        _types = types;
        _isLoadingData = false;

        if (widget.route != null) {
          _routeNumberController.text = widget.route!.routeNumber;
          _distanceController.text = widget.route!.distanceKm.toString();
          _durationController.text = widget.route!.estimatedDurationMinutes.toString();
          
          try {
            _startCity = _cities.firstWhere((c) => c.id == widget.route!.startCity.id);
            _endCity = _cities.firstWhere((c) => c.id == widget.route!.endCity.id);
            _transportType = _types.firstWhere((t) => t.id == widget.route!.transportType.id);
          } catch (_) {}
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _routeNumberController.dispose();
    _distanceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startCity == null || _endCity == null || _transportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select all required fields')));
      return;
    }
    if (_startCity!.id == _endCity!.id) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Start and End city cannot be same')));
       return;
    }

    setState(() => _isSubmitting = true);

    final route = RouteModel(
      id: widget.route?.id ?? 0,
      routeNumber: _routeNumberController.text.trim(),
      transportType: _transportType!,
      startCity: _startCity!,
      endCity: _endCity!,
      distanceKm: double.parse(_distanceController.text.trim()),
      estimatedDurationMinutes: int.parse(_durationController.text.trim()),
      isActive: widget.route?.isActive ?? true,
    );

    final result = widget.route != null 
        ? await _routeService.updateRoute(widget.route!.id, route)
        : await _routeService.createRoute(route);

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
      title: Text(widget.route != null ? 'Edit Route' : 'Add Route'),
      content: _isLoadingData
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _routeNumberController,
                      decoration: const InputDecoration(labelText: 'Route Number *', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TransportTypeModel>(
                      value: _transportType,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Transport Type *', border: OutlineInputBorder()),
                      items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t.name, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _transportType = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CityModel>(
                      value: _startCity,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Start City *', border: OutlineInputBorder()),
                      items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c.name, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _startCity = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<CityModel>(
                      value: _endCity,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'End City *', border: OutlineInputBorder()),
                      items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c.name, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => _endCity = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _distanceController,
                      decoration: const InputDecoration(labelText: 'Distance (KM) *', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(labelText: 'Duration (Minutes) *', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
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
              : Text(widget.route != null ? 'Update' : 'Create', style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
