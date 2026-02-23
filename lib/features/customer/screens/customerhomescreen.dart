import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurantviewscreen.dart';

class CustomerHomeScreen extends StatefulWidget {
  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  
  String selectedCategory = 'All';
  String searchQuery = '';
  int cartItemCount = 0;
  
  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.grid_view},
    {'name': 'Hot Dog', 'icon': Icons.lunch_dining},
    {'name': 'Burger', 'icon': Icons.lunch_dining},
    {'name': 'Pizza', 'icon': Icons.local_pizza},
    {'name': 'Sushi', 'icon': Icons.set_meal},
  ];

  @override
  void initState() {
    super.initState();
    _loadCartCount();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load cart item count (you'll implement this with your cart logic)
  Future<void> _loadCartCount() async {
    // TODO: Implement actual cart count logic
    // For now, using dummy data
    setState(() {
      cartItemCount = 2;
    });
  }

  // Filter restaurants based on search and category
  bool _filterRestaurant(Map<String, dynamic> restaurant) {
    // Filter by search query
    if (searchQuery.isNotEmpty) {
      String name = (restaurant['name'] ?? '').toLowerCase();
      String categories = (restaurant['categories'] ?? '').toLowerCase();
      
      if (!name.contains(searchQuery) && !categories.contains(searchQuery)) {
        return false;
      }
    }

    // Filter by category
    if (selectedCategory != 'All') {
      String categories = (restaurant['categories'] ?? '').toLowerCase();
      if (!categories.contains(selectedCategory.toLowerCase())) {
        return false;
      }
    }

    return true;
  }

  // Show drawer menu
  void _openDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DrawerMenu(),
    );
  }

  // Navigate to cart
  void _openCart() {
    // TODO: Navigate to cart screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cart screen coming soon!'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Clear search
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menu Icon
                  GestureDetector(
                    onTap: _openDrawer,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.menu, color: Colors.black87),
                    ),
                  ),
                  // Cart Icon with Badge
                  GestureDetector(
                    onTap: _openCart,
                    child: Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFF1A1B2E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.shopping_bag_outlined, color: Colors.white),
                        ),
                        if (cartItemCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  cartItemCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Sen',
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Welcome Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome To Quickfood',
                    style: TextStyle(
                      fontFamily: 'Sen',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (user?.displayName != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'Hi, ${user!.displayName}!',
                      style: TextStyle(
                        fontFamily: 'Sen',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search dishes, restaurants',
                          hintStyle: TextStyle(
                            fontFamily: 'Sen',
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: _clearSearch,
                        child: Icon(Icons.close, color: Colors.grey, size: 20),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // All Categories Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Categories',
                    style: TextStyle(
                      fontFamily: 'Sen',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to categories screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('All categories view coming soon!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'See All',
                          style: TextStyle(
                            fontFamily: 'Sen',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.black54, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Categories List
            Container(
              height: 60,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category['name'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category['name'];
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFFFFB347) : Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              category['icon'],
                              color: isSelected ? Colors.white : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                          if (isSelected) ...[
                            SizedBox(width: 8),
                            Text(
                              category['name'],
                              style: TextStyle(
                                fontFamily: 'Sen',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 24),

            // Open Restaurants Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Open Restaurants',
                    style: TextStyle(
                      fontFamily: 'Sen',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to all restaurants
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('All restaurants view coming soon!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'See All',
                          style: TextStyle(
                            fontFamily: 'Sen',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.black54, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Restaurant List with Filtering
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('restaurants').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading restaurants'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.orange));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No restaurants available',
                            style: TextStyle(
                              fontFamily: 'Sen',
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter restaurants
                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    var restaurant = doc.data() as Map<String, dynamic>;
                    return _filterRestaurant(restaurant);
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No restaurants found',
                            style: TextStyle(
                              fontFamily: 'Sen',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            searchQuery.isNotEmpty 
                                ? 'Try a different search term'
                                : 'Try selecting a different category',
                            style: TextStyle(
                              fontFamily: 'Sen',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var doc = filteredDocs[index];
                      var restaurant = doc.data() as Map<String, dynamic>;
                      
                      return RestaurantCard(
                        restaurantId: doc.id,
                        name: restaurant['name'] ?? 'Restaurant',
                        categories: restaurant['categories'] ?? 'Food',
                        rating: (restaurant['rating'] ?? 4.7).toDouble(),
                        deliveryTime: restaurant['deliveryTime'] ?? '20 min',
                        imageUrl: restaurant['imageUrl'] ?? '',
                        description: restaurant['description'] ?? '',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String restaurantId;
  final String name;
  final String categories;
  final double rating;
  final String deliveryTime;
  final String imageUrl;
  final String description;

  const RestaurantCard({
    required this.restaurantId,
    required this.name,
    required this.categories,
    required this.rating,
    required this.deliveryTime,
    this.imageUrl = '',
    this.description = '',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantViewScreen(
              restaurantId: restaurantId,
              restaurantName: name,
              restaurantImage: imageUrl,
              description: description,
              rating: rating,
              deliveryTime: deliveryTime,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFB0BEC5),
                borderRadius: BorderRadius.circular(16),
                image: imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    )
                  : null,
            ),
            SizedBox(height: 12),
            // Restaurant Name
            Text(
              name,
              style: TextStyle(
                fontFamily: 'Sen',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            // Categories
            Text(
              categories,
              style: TextStyle(
                fontFamily: 'Sen',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            // Rating and Delivery Time
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange, size: 20),
                SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: TextStyle(
                    fontFamily: 'Sen',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.access_time, color: Colors.orange, size: 20),
                SizedBox(width: 4),
                Text(
                  deliveryTime,
                  style: TextStyle(
                    fontFamily: 'Sen',
                    fontSize: 14,
                    color: Colors.black87,
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

// Drawer Menu Widget
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
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to profile
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'My Orders',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to orders
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.favorite_outline,
                  title: 'Favorites',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to favorites
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to settings
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to support
                  },
                ),
                Divider(),
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
      leading: Icon(
        icon,
        color: iconColor ?? Colors.black87,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Sen',
          fontSize: 16,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}