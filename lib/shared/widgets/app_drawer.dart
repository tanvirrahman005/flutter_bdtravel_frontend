import 'package:flutter/material.dart';
import 'package:bd_travel/core/constants/app_colors.dart';
import 'package:bd_travel/core/constants/app_strings.dart';
import 'package:bd_travel/core/constants/app_routes.dart';
import 'package:bd_travel/services/auth_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  String _username = 'Guest User';
  String _email = 'guest@bdtravel.com';
  String _role = 'USER';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final userData = await _authService.getCurrentUser();
      setState(() {
        _isLoggedIn = true;
        _username = userData['username'] ?? 'User';
        _email = userData['email'] ?? 'user@bdtravel.com';
        _role = userData['role'] ?? 'USER';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_circle,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    if (_isLoggedIn) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _role == 'ADMIN' 
                              ? Colors.amber.withOpacity(0.3)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _role == 'ADMIN' 
                              ? '👑 Admin' 
                              : (_role == 'OPERATOR' ? '🛠️ Operator' : '👤 User'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  route: AppRoutes.home,
                ),
                
                // Role-based menu items
                if (_isLoggedIn && _role == 'ADMIN') ...[
                  _buildMenuItem(
                    context,
                    icon: Icons.admin_panel_settings,
                    title: 'Admin Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Admin Dashboard - Coming Soon'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.people,
                    title: 'User List',
                    route: AppRoutes.userList,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.airport_shuttle,
                    title: 'Transport Companies',
                    route: AppRoutes.transportCompanies,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.category,
                    title: 'Transport Types',
                    route: AppRoutes.transportTypes,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.location_city,
                    title: 'Cities',
                    route: AppRoutes.cities,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.directions_bus,
                    title: 'Vehicles',
                    route: AppRoutes.vehicles,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.event_seat,
                    title: 'Seat Layouts',
                    route: AppRoutes.seatLayouts,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.map,
                    title: 'Routes',
                    route: AppRoutes.transportRoutes,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.schedule,
                    title: 'Schedules',
                    route: AppRoutes.schedules,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.book_online,
                    title: 'Bookings',
                    route: AppRoutes.adminBookings,
                  ),
                ],
                
                // Operator only section (if any separate)
                if (_isLoggedIn && _role == 'OPERATOR') ...[
                   _buildMenuItem(
                    context,
                    icon: Icons.event_seat,
                    title: 'Seat Layouts',
                    route: AppRoutes.seatLayouts,
                  ),
                   _buildMenuItem(
                    context,
                    icon: Icons.map,
                    title: 'Routes',
                    route: AppRoutes.transportRoutes,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.schedule,
                    title: 'Schedules',
                    route: AppRoutes.schedules,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.book_online,
                    title: 'Bookings',
                    route: AppRoutes.adminBookings,
                  ),
                ],
                
                if (_isLoggedIn && _role != 'ADMIN') ...[
                  _buildMenuItem(
                    context,
                    icon: Icons.confirmation_number,
                    title: AppStrings.myBookings,
                    route: AppRoutes.myBookings,
                  ),
                ],
                
                _buildMenuItem(
                  context,
                  icon: Icons.person,
                  title: AppStrings.profile,
                  route: AppRoutes.profile,
                ),
                
                const Divider(height: 1),
                
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help & Support - Coming Soon'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // App Version
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'BD Travel v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
  }) {
    final isCurrentRoute = route != null && ModalRoute.of(context)?.settings.name == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isCurrentRoute ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isCurrentRoute ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isCurrentRoute ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isCurrentRoute,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      onTap: onTap ??
          () {
            if (route != null) {
              Navigator.pop(context); // Close drawer
              if (!isCurrentRoute) {
                Navigator.pushNamed(context, route);
              }
            }
          },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text('About BD Travel'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appTagline,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'BD Travel is your trusted companion for booking bus tickets across Bangladesh. '
              'We provide a seamless booking experience with real-time seat availability, '
              'multiple payment options, and instant confirmation.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Version: 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
