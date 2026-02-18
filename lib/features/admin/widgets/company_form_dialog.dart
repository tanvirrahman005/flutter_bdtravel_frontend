import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/transport_company_model.dart';
import 'package:bd_travel/services/transport_company_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';

class CompanyFormDialog extends StatefulWidget {
  final TransportCompanyModel? company;

  const CompanyFormDialog({super.key, this.company});

  @override
  State<CompanyFormDialog> createState() => _CompanyFormDialogState();
}

class _CompanyFormDialogState extends State<CompanyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _logoController = TextEditingController();
  final TransportCompanyService _companyService = TransportCompanyService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _nameController.text = widget.company!.name;
      _codeController.text = widget.company!.code ?? '';
      _contactController.text = widget.company!.contactNumber ?? '';
      _emailController.text = widget.company!.email ?? '';
      _addressController.text = widget.company!.address ?? '';
      _logoController.text = widget.company!.logoUrl ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final company = TransportCompanyModel(
      id: widget.company?.id ?? 0,
      name: _nameController.text.trim(),
      code: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
      contactNumber: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      logoUrl: _logoController.text.trim().isEmpty ? null : _logoController.text.trim(),
      isActive: widget.company?.isActive ?? true,
    );

    Map<String, dynamic> result;
    if (widget.company != null) {
      result = await _companyService.updateCompany(widget.company!.id, company);
    } else {
      result = await _companyService.createCompany(company);
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
      title: Text(widget.company != null ? 'Edit Company' : 'Add Company'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Company Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                maxLength: 10,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _logoController,
                decoration: const InputDecoration(
                  labelText: 'Logo URL (Online Image)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                  helperText: 'Enter online image URL (e.g., https://example.com/logo.png)',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final urlRegex = RegExp(r'^https?://');
                    if (!urlRegex.hasMatch(value)) {
                      return 'Please enter a valid URL starting with http:// or https://';
                    }
                  }
                  return null;
                },
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
                  widget.company != null ? 'Update' : 'Create',
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
