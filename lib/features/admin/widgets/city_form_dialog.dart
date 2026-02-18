import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/city_model.dart';
import 'package:bd_travel/services/city_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';

class CityFormDialog extends StatefulWidget {
  final CityModel? city;

  const CityFormDialog({super.key, this.city});

  @override
  State<CityFormDialog> createState() => _CityFormDialogState();
}

class _CityFormDialogState extends State<CityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bnNameController = TextEditingController();
  final _codeController = TextEditingController();
  final CityService _cityService = CityService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.city != null) {
      _nameController.text = widget.city!.name;
      _bnNameController.text = widget.city!.bnName ?? '';
      _codeController.text = widget.city!.code ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bnNameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final city = CityModel(
      id: widget.city?.id ?? 0,
      name: _nameController.text.trim(),
      bnName: _bnNameController.text.trim().isEmpty ? null : _bnNameController.text.trim(),
      code: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
      isActive: widget.city?.isActive ?? true,
    );

    Map<String, dynamic> result;
    if (widget.city != null) {
      result = await _cityService.updateCity(widget.city!.id, city);
    } else {
      result = await _cityService.createCity(city);
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
      title: Text(widget.city != null ? 'Edit City' : 'Add City'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'City Name (English) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                  hintText: 'e.g., Dhaka, Chittagong',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter city name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bnNameController,
                decoration: const InputDecoration(
                  labelText: 'City Name (Bengali)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language),
                  hintText: 'e.g., ঢাকা, চট্টগ্রাম',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'City Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                  hintText: 'e.g., DHK, CTG',
                ),
                maxLength: 10,
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
          onPressed: _isLoading ? null : _submit,
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
                  widget.city != null ? 'Update' : 'Create',
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
