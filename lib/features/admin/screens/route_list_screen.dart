import 'package:flutter/material.dart';
import 'package:bd_travel/data/models/route_model.dart';
import 'package:bd_travel/services/route_service.dart';
import 'package:bd_travel/services/storage_service.dart';
import 'package:bd_travel/core/constants/app_colors.dart';
import 'package:bd_travel/features/admin/widgets/route_form_dialog.dart';

class RouteListScreen extends StatefulWidget {
  const RouteListScreen({super.key});

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  final RouteService _routeService = RouteService();
  List<RouteModel> _routes = [];
  bool _isLoading = true;
  bool _isAdminOrOperator = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
    _loadRoutes();
  }

  Future<void> _checkRole() async {
    final role = await StorageService.getRole();
    if (mounted) {
      setState(() {
        _isAdminOrOperator = role == 'ADMIN' || role == 'OPERATOR';
      });
    }
  }

  Future<void> _loadRoutes() async {
    setState(() => _isLoading = true);
    try {
      final routes = await _routeService.getAllRoutes();
      if (mounted) {
        setState(() {
          _routes = routes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading routes: $e')));
      }
    }
  }

  Future<void> _toggleStatus(RouteModel route) async {
    final result = await _routeService.toggleRouteStatus(route.id, !route.isActive);
    if (result['success']) {
      _loadRoutes();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  Future<void> _deleteRoute(RouteModel route) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: Text('Are you sure you want to delete route ${route.routeNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _routeService.deleteRoute(route.id);
      if (result['success']) {
        _loadRoutes();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Routes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRoutes,
              child: _routes.isEmpty
                  ? const Center(child: Text('No routes found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _routes.length,
                      itemBuilder: (context, index) {
                        final route = _routes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: route.isActive ? AppColors.primary : Colors.grey,
                                      child: const Icon(Icons.map, color: Colors.white),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${route.startCity.name} ➔ ${route.endCity.name}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Route: ${route.routeNumber} | Type: ${route.transportType.name}',
                                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${route.distanceKm} km',
                                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${route.estimatedDurationMinutes} min',
                                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_isAdminOrOperator)
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            showDialog(context: context, builder: (context) => RouteFormDialog(route: route)).then((value) { if (value == true) _loadRoutes(); });
                                          } else if (value == 'toggle') {
                                            _toggleStatus(route);
                                          } else if (value == 'delete') {
                                            _deleteRoute(route);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit', 
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, size: 20),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'toggle', 
                                            child: Row(
                                              children: [
                                                Icon(
                                                  route.isActive ? Icons.block : Icons.check_circle, 
                                                  size: 20, 
                                                  color: route.isActive ? Colors.orange : Colors.green
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  route.isActive ? 'Deactivate' : 'Activate',
                                                  style: TextStyle(color: route.isActive ? Colors.orange : Colors.green),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
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
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'ID: ${route.id}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: route.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: route.isActive ? Colors.green : Colors.red,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        route.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: route.isActive ? Colors.green : Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: _isAdminOrOperator
          ? FloatingActionButton(
              onPressed: () => showDialog(context: context, builder: (context) => const RouteFormDialog()).then((value) { if (value == true) _loadRoutes(); }),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
