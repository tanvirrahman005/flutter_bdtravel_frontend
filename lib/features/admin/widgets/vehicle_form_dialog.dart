import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/vehicle_model.dart';
import 'package:bd_travel/data/models/transport_company_model.dart';
import 'package:bd_travel/data/models/transport_type_model.dart';
import 'package:bd_travel/services/vehicle_service.dart';
import 'package:bd_travel/services/transport_company_service.dart';
import 'package:bd_travel/services/transport_type_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';

class VehicleFormDialog extends StatefulWidget {
  final VehicleModel? vehicle;

  const VehicleFormDialog({super.key, this.vehicle});

  @override
  State<VehicleFormDialog> createState() => _VehicleFormDialogState();
}

class _VehicleFormDialogState extends State<VehicleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _totalSeatsController = TextEditingController();
  final _facilitiesController = TextEditingController();
  
  final VehicleService _vehicleService = VehicleService();
  final TransportCompanyService _companyService = TransportCompanyService();
  final TransportTypeService _typeService = TransportTypeService();

  bool _isLoading = false;
  bool _isLoadingData = true;
  
  List<TransportCompanyModel> _companies = [];
  List<TransportTypeModel> _types = [];
  TransportCompanyModel? _selectedCompany;
  TransportTypeModel? _selectedType;
  String _selectedVehicleType = 'LOWER';

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      final companies = await _companyService.getActiveCompanies();
      final types = await _typeService.getAllTransportTypes();

      if (!mounted) return;

      setState(() {
        _companies = companies;
        _types = types;
        _isLoadingData = false;
      });

      if (widget.vehicle != null) {
        _vehicleNumberController.text = widget.vehicle!.vehicleNumber;
        _modelController.text = widget.vehicle!.model ?? '';
        _totalSeatsController.text = widget.vehicle!.totalSeats.toString();
        _facilitiesController.text = widget.vehicle!.facilities ?? '';
        _selectedVehicleType = widget.vehicle!.vehicleType;
        
        // Find existing company and type in the lists
        try {
          _selectedCompany = _companies.firstWhere((c) => c.id == widget.vehicle!.transportCompany.id);
        } catch (_) {}
        
        try {
          _selectedType = _types.firstWhere((t) => t.id == widget.vehicle!.transportType.id);
        } catch (_) {}
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading form data: $e')),
      );
    }
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _modelController.dispose();
    _totalSeatsController.dispose();
    _facilitiesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a company')),
      );
      return;
    }
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a transport type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final vehicle = VehicleModel(
      id: widget.vehicle?.id ?? 0,
      transportCompany: _selectedCompany!,
      transportType: _selectedType!,
      vehicleNumber: _vehicleNumberController.text.trim(),
      model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
      totalSeats: int.parse(_totalSeatsController.text.trim()),
      vehicleType: _selectedVehicleType,
      facilities: _facilitiesController.text.trim().isEmpty ? null : _facilitiesController.text.trim(),
      isActive: widget.vehicle?.isActive ?? true,
    );

    Map<String, dynamic> result;
    if (widget.vehicle != null) {
      result = await _vehicleService.updateVehicle(widget.vehicle!.id, vehicle);
    } else {
      result = await _vehicleService.createVehicle(vehicle);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.vehicle != null ? 'Edit Vehicle' : 'Add Vehicle'),
      content: _isLoadingData
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Transport Company *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TransportCompanyModel>(
                          value: _selectedCompany,
                          isExpanded: true,
                          hint: const Text('Select Company'),
                          items: _companies.map((company) {
                            return DropdownMenuItem(
                              value: company,
                              child: Text(company.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCompany = value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Transport Type *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TransportTypeModel>(
                          value: _selectedType,
                          isExpanded: true,
                          hint: const Text('Select Type'),
                          items: _types.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedType = value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _vehicleNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Number *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.confirmation_number),
                        hintText: 'e.g., DHAKA METRO-B 11-1234',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter vehicle number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _totalSeatsController,
                            decoration: const InputDecoration(
                              labelText: 'Total Seats *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.event_seat),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Deck Type',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedVehicleType,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'LOWER', child: Text('Single/Lower')),
                                  DropdownMenuItem(value: 'UPPER', child: Text('Double Decker')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedVehicleType = value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_bus),
                        hintText: 'e.g., Hino 1J',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _facilitiesController,
                      decoration: const InputDecoration(
                        labelText: 'Facilities',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.wifi),
                        hintText: 'e.g., Wifi, AC, TV',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _isLoadingData ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.vehicle != null ? 'Update' : 'Create',
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
