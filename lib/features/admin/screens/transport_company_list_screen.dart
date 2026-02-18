import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/transport_company_model.dart';
import 'package:bd_travel/services/storage_service.dart';
import 'package:bd_travel/services/transport_company_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';
import 'package:bd_travel/features/admin/widgets/company_form_dialog.dart';

class TransportCompanyListScreen extends StatefulWidget {
  const TransportCompanyListScreen({super.key});

  @override
  State<TransportCompanyListScreen> createState() => _TransportCompanyListScreenState();
}

class _TransportCompanyListScreenState extends State<TransportCompanyListScreen> {
  final TransportCompanyService _companyService = TransportCompanyService();
  List<TransportCompanyModel> _companies = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
    _loadCompanies();
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

  Future<void> _loadCompanies() async {
    setState(() => _isLoading = true);
    try {
      final companies = await _companyService.getAllCompanies();
      setState(() {
        _companies = companies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading companies: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _showCompanyForm({TransportCompanyModel? company}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CompanyFormDialog(company: company),
    );

    if (result == true) {
      _loadCompanies(); // Refresh list
    }
  }

  Future<void> _toggleCompanyStatus(TransportCompanyModel company) async {
    final action = company.isActive ? 'deactivate' : 'activate';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action == 'activate' ? 'Activate' : 'Deactivate'} Company'),
        content: Text(
          'Are you sure you want to $action ${company.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: company.isActive ? Colors.orange : Colors.green,
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

      final result = await _companyService.toggleCompanyStatus(company.id, !company.isActive);
      
      if (!mounted) return;
      Navigator.pop(context); // Hide loading

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        _loadCompanies(); // Refresh list
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

  Future<void> _deleteCompany(TransportCompanyModel company) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Company'),
        content: Text(
          'Are you sure you want to delete ${company.name}? This action cannot be undone.',
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

      final result = await _companyService.deleteCompany(company.id);
      
      if (!mounted) return;
      Navigator.pop(context); // Hide loading

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        _loadCompanies(); // Refresh list
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
        title: const Text('Transport Companies'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCompanies,
              child: _companies.isEmpty
                  ? const Center(
                      child: Text(
                        'No companies found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _companies.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final company = _companies[index];
                        return _buildCompanyCard(company);
                      },
                    ),
            ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => _showCompanyForm(),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildCompanyCard(TransportCompanyModel company) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: company.logoUrl != null && company.logoUrl!.isNotEmpty
            ? CircleAvatar(
                backgroundColor: Colors.white,
                radius: 24,
                child: ClipOval(
                  child: Image.network(
                    company.logoUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to initial if image fails to load
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: company.isActive ? AppColors.primary : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            company.name.isNotEmpty ? company.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      );
                    },
                  ),
                ),
              )
            : CircleAvatar(
                backgroundColor: company.isActive ? AppColors.primary : Colors.grey,
                radius: 24,
                child: Text(
                  company.name.isNotEmpty ? company.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                company.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (company.code != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Text(
                  company.code!,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (company.contactNumber != null)
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(company.contactNumber!),
                ],
              ),
            if (company.email != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.email, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(company.email!)),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'ID: ${company.id}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: company.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: company.isActive ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    company.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: company.isActive ? Colors.green : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') _showCompanyForm(company: company);
            if (value == 'toggle') _toggleCompanyStatus(company);
            if (value == 'delete') _deleteCompany(company);
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
                    company.isActive ? Icons.block : Icons.check_circle,
                    size: 20,
                    color: company.isActive ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    company.isActive ? 'Deactivate' : 'Activate',
                    style: TextStyle(
                      color: company.isActive ? Colors.orange : Colors.green,
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
      ),
    );
  }
}
