import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerHomeScreen extends StatefulWidget {
  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String selectedCategory = 'All';
  
  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.grid_view},
    {'name': 'Hot Dog', 'icon': Icons.lunch_dining},
    {'name': 'Burger', 'icon': Icons.lunch_dining},
    {'name': 'Pizza', 'icon': Icons.local_pizza},
    {'name': 'Sushi', 'icon': Icons.set_meal},
  ];

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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.menu, color: Colors.black87),
                  ),
                  // Cart Icon with Badge
                  Stack(
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
                              '2',
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
                ],
              ),
            ),

            // Welcome Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Welcome To Quickfood',
                style: TextStyle(
                  fontFamily: 'Sen',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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
                  Row(
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
                  Row(
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
                ],
              ),
            ),

            SizedBox(height: 16),

            // Restaurant List
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

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var restaurant = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return RestaurantCard(
                        name: restaurant['name'] ?? 'Restaurant',
                        categories: restaurant['categories'] ?? 'Food',
                        rating: (restaurant['rating'] ?? 4.7).toDouble(),
                        deliveryTime: restaurant['deliveryTime'] ?? '20 min',
                        imageUrl: restaurant['imageUrl'] ?? '',
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
  final String name;
  final String categories;
  final double rating;
  final String deliveryTime;
  final String imageUrl;

  const RestaurantCard({
    required this.name,
    required this.categories,
    required this.rating,
    required this.deliveryTime,
    this.imageUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}