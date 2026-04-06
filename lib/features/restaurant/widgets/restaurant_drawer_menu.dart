import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RestaurantDrawerMenu extends StatelessWidget {
  final User? user;
  final bool isOpen;
  final VoidCallback onDashboardTap;
  final VoidCallback onToggleOpenTap;
  final VoidCallback onOrderRequestsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const RestaurantDrawerMenu({
    super.key,
    required this.user,
    required this.isOpen,
    required this.onDashboardTap,
    required this.onToggleOpenTap,
    required this.onOrderRequestsTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.orange,
                  child: Text(
                    user?.displayName?.substring(0, 1).toUpperCase() ?? 'R',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Sen',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Restaurant',
                        style: const TextStyle(
                          fontFamily: 'Sen',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          fontFamily: 'Sen',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  onTap: onDashboardTap,
                ),
                _buildDrawerItem(
                  icon: isOpen ? Icons.storefront : Icons.store_mall_directory_outlined,
                  title: isOpen ? 'Set Restaurant Closed' : 'Set Restaurant Open',
                  iconColor: isOpen ? Colors.green : Colors.orange,
                  onTap: onToggleOpenTap,
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order Requests',
                  onTap: onOrderRequestsTap,
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: onSettingsTap,
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: onLogoutTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black87, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Sen',
          fontSize: 16,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
