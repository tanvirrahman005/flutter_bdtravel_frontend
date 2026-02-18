import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/transport_type_model.dart';
import 'package:bd_travel/services/transport_type_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';

class TransportTypeFormDialog extends StatefulWidget {
  final TransportTypeModel? type;

  const TransportTypeFormDialog({super.key, this.type});

  @override
  State<TransportTypeFormDialog> createState() => _TransportTypeFormDialogState();
}

class _TransportTypeFormDialogState extends State<TransportTypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TransportTypeService _typeService = TransportTypeService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.type != null) {
      _nameController.text = widget.type!.name;
      _descriptionController.text = widget.type!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final type = TransportTypeModel(
      id: widget.type?.id ?? 0,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    );

    Map<String, dynamic> result;
    if (widget.type != null) {
      result = await _typeService.updateTransportType(widget.type!.id, type);
    } else {
      result = await _typeService.createTransportType(type);
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
      title: Text(widget.type != null ? 'Edit Transport Type' : 'Add Transport Type'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Type Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_bus),
                  hintText: 'e.g., AC Bus, Non-AC, Train, etc.',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter type name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Optional description',
                ),
                maxLines: 3,
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
                  widget.type != null ? 'Update' : 'Create',
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
