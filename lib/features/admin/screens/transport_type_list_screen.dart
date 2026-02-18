import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/transport_type_model.dart';
import 'package:bd_travel/services/storage_service.dart';
import 'package:bd_travel/services/transport_type_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';
import 'package:bd_travel/features/admin/widgets/transport_type_form_dialog.dart';

class TransportTypeListScreen extends StatefulWidget {
  const TransportTypeListScreen({super.key});

  @override
  State<TransportTypeListScreen> createState() => _TransportTypeListScreenState();
}

class _TransportTypeListScreenState extends State<TransportTypeListScreen> {
  final TransportTypeService _typeService = TransportTypeService();
  List<TransportTypeModel> _types = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
    _loadTypes();
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

  Future<void> _loadTypes() async {
    setState(() => _isLoading = true);
    try {
      final types = await _typeService.getAllTransportTypes();
      setState(() {
        _types = types;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading transport types: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _showTypeForm({TransportTypeModel? type}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TransportTypeFormDialog(type: type),
    );

    if (result == true) {
      _loadTypes(); // Refresh list
    }
  }

  Future<void> _deleteType(TransportTypeModel type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transport Type'),
        content: Text(
          'Are you sure you want to delete "${type.name}"? This action cannot be undone.',
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

      final result = await _typeService.deleteTransportType(type.id);
      
      if (!mounted) return;
      Navigator.pop(context); // Hide loading

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        _loadTypes(); // Refresh list
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
        title: const Text('Transport Types'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTypes,
              child: _types.isEmpty
                  ? const Center(
                      child: Text(
                        'No transport types found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _types.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final type = _types[index];
                        return _buildTypeCard(type);
                      },
                    ),
            ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => _showTypeForm(),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildTypeCard(TransportTypeModel type) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(
            Icons.directions_bus,
            color: Colors.white,
          ),
        ),
        title: Text(
          type.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: type.description != null && type.description!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  type.description!,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ID: ${type.id}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _showTypeForm(type: type);
                if (value == 'delete') _deleteType(type);
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
      ),
    );
  }
}
