import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedMenuData() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final WriteBatch batch = firestore.batch();

  // Restaurant 1: Pizza & Pasta
  const String restaurantId1 = "ecCXggakWKgVzDrzwsnw";
  final List<Map<String, dynamic>> menuItems1 = [
    {'name': 'Margherita Pizza', 'category': 'Pizza', 'price': 450, 'imageUrl': 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500'},
    {'name': 'Pepperoni Pizza', 'category': 'Pizza', 'price': 520, 'imageUrl': 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500'},
    {'name': 'Quattro Formaggi', 'category': 'Pizza', 'price': 580, 'imageUrl': 'https://images.unsplash.com/photo-1595521624512-37a97faf77be?w=500'},
    {'name': 'Spaghetti Carbonara', 'category': 'Pasta', 'price': 480, 'imageUrl': 'https://images.unsplash.com/photo-1612874742237-6526221fcf4f?w=500'},
    {'name': 'Fettuccine Alfredo', 'category': 'Pasta', 'price': 450, 'imageUrl': 'https://images.unsplash.com/photo-1645112411341-6c4ee32510d8?w=500'},
  ];

  // Restaurant 2: Burger & American
  const String restaurantId2 = "jo2p55Hpa8jZZYOvPQu1";
  final List<Map<String, dynamic>> menuItems2 = [
    {'name': 'Classic Burger', 'category': 'Burger', 'price': 500, 'imageUrl': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500'},
    {'name': 'Double Cheese Burger', 'category': 'Burger', 'price': 580, 'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500'},
    {'name': 'Bacon Burger', 'category': 'Burger', 'price': 620, 'imageUrl': 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=500'},
    {'name': 'Crispy Fries', 'category': 'Fries', 'price': 180, 'imageUrl': 'https://images.unsplash.com/photo-1584622566949-a8c4a36d0e09?w=500'},
    {'name': 'Loaded Fries', 'category': 'Fries', 'price': 320, 'imageUrl': 'https://images.unsplash.com/photo-1585238341710-4b8f6e8d1e0d?w=500'},
  ];

  for (var item in menuItems1) {
    DocumentReference docRef = firestore
        .collection('restaurants')
        .doc(restaurantId1)
        .collection('menu')
        .doc();
    batch.set(docRef, item);
  }

  for (var item in menuItems2) {
    DocumentReference docRef = firestore
        .collection('restaurants')
        .doc(restaurantId2)
        .collection('menu')
        .doc();
    batch.set(docRef, item);
  }

  try {
    await batch.commit();
    print("✅ Menu data uploaded successfully!");
  } catch (e) {
    print("❌ Error uploading menu: $e");
  }
}

class DrawerMenu extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // User Profile Section
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.orange,
                  child: Text(
                    user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Sen',
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'User',
                        style: TextStyle(
                          fontFamily: 'Sen',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
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

          Divider(),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(context, icon: Icons.person_outline, title: 'Profile', onTap: () { Navigator.pop(context); }),
                _buildMenuItem(context, icon: Icons.receipt_long_outlined, title: 'My Orders', onTap: () { Navigator.pop(context); }),
                _buildMenuItem(context, icon: Icons.favorite_outline, title: 'Favorites', onTap: () { Navigator.pop(context); }),
                _buildMenuItem(context, icon: Icons.settings_outlined, title: 'Settings', onTap: () { Navigator.pop(context); }),
                _buildMenuItem(context, icon: Icons.help_outline, title: 'Help & Support', onTap: () { Navigator.pop(context); }),
                Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.data_usage,
                  title: 'Seed Menu Data',
                  onTap: () async {
                    Navigator.pop(context);
                    await seedMenuData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Menu data seeding initiated!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () async {
                    await _auth.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                ),
              ],
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
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black87, size: 24),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'Sen', fontSize: 16, color: textColor ?? Colors.black87),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
