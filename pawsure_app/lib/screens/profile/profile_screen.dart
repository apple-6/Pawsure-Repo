import 'package:flutter/material.dart';
import 'package:pawsure_app/screens/profile/my_pets_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userRole;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile or settings
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : "B",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userRole, // e.g., "Role: Pet Owner"
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.teal[100]),
                  onPressed: () {
                    // Navigate to edit profile screen
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Menu List
            _buildMenuItem(
              context,
              title: 'My Pets',
              icon: Icons.pets,
              onTap: () {
                // Navigate to My Pets screen
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MyPetsScreen()),
                );
              },
            ),
            _buildMenuItem(
              context,
              title: 'My Favourite Sitters',
              icon: Icons.favorite_border,
              onTap: () {
                // Navigate to My Favourite Sitters screen
              },
            ),
            _buildMenuItem(
              context,
              title: 'Payment Methods',
              icon: Icons.payment,
              onTap: () {
                // Navigate to Payment Methods screen
              },
            ),
            _buildMenuItem(
              context,
              title: 'Settings',
              icon: Icons.settings,
              onTap: () {
                // Navigate to Settings screen
              },
            ),
            const SizedBox(height: 24),

            // Role Section (Become a Sitter)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                'ROLE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context,
              title: 'Become a Sitter',
              icon: Icons.arrow_forward,
              onTap: () {
                // Navigate to Become a Sitter screen
              },
            ),
            const SizedBox(height: 24),

            // Help and Log Out Section
            _buildMenuItem(
              context,
              title: 'Help & Support',
              icon: Icons.help_outline,
              onTap: () {
                // Navigate to Help & Support screen
              },
            ),
            _buildMenuItem(
              context,
              title: 'Log Out',
              icon: Icons.exit_to_app,
              onTap: () {
                // Log out action
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each menu item
  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(title),
      onTap: onTap,
    );
  }
}
