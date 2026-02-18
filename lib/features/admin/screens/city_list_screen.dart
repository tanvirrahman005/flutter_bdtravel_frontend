import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/city_model.dart';
import 'package:bd_travel/services/storage_service.dart';
import 'package:bd_travel/services/city_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';
import 'package:bd_travel/features/admin/widgets/city_form_dialog.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  final CityService _cityService = CityService();
  List<CityModel> _cities = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
    _loadCities();
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

  Future<void> _loadCities() async {
    setState(() => _isLoading = true);
    try {
      final cities = await _cityService.getAllCities();
      setState(() {
        _cities = cities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading cities: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _showCityForm({CityModel? city}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CityFormDialog(city: city),
    );

    if (result == true) {
      _loadCities(); // Refresh list
    }
  }

  Future<void> _toggleCityStatus(CityModel city) async {
    final action = city.isActive ? 'deactivate' : 'activate';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action == 'activate' ? 'Activate' : 'Deactivate'} City'),
        content: Text(
          'Are you sure you want to $action ${city.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: city.isActive ? Colors.orange : Colors.green,
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

      final result = await _cityService.toggleCityStatus(city.id, !city.isActive);
      
      if (!mounted) return;
      Navigator.pop(context); // Hide loading

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        _loadCities(); // Refresh list
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

  Future<void> _deleteCity(CityModel city) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete City'),
        content: Text(
          'Are you sure you want to delete ${city.name}? This action cannot be undone.',
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

      final result = await _cityService.deleteCity(city.id);
      
      if (!mounted) return;
      Navigator.pop(context); // Hide loading

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.success,
          ),
        );
        _loadCities(); // Refresh list
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
        title: const Text('Cities'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCities,
              child: _cities.isEmpty
                  ? const Center(
                      child: Text(
                        'No cities found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _cities.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final city = _cities[index];
                        return _buildCityCard(city);
                      },
                    ),
            ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => _showCityForm(),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildCityCard(CityModel city) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: city.isActive ? AppColors.primary : Colors.grey,
          child: const Icon(Icons.location_city, color: Colors.white),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                city.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (city.code != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Text(
                  city.code!,
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
            if (city.bnName != null && city.bnName!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                city.bnName!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'ID: ${city.id}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: city.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: city.isActive ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    city.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: city.isActive ? Colors.green : Colors.red,
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
            if (value == 'edit') _showCityForm(city: city);
            if (value == 'toggle') _toggleCityStatus(city);
            if (value == 'delete') _deleteCity(city);
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
                    city.isActive ? Icons.block : Icons.check_circle,
                    size: 20,
                    color: city.isActive ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    city.isActive ? 'Deactivate' : 'Activate',
                    style: TextStyle(
                      color: city.isActive ? Colors.orange : Colors.green,
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
