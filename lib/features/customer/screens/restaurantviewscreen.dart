import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'itemdetailsscreen.dart';

class RestaurantViewScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final String description;
  final double rating;
  final String deliveryTime;

  const RestaurantViewScreen({
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantImage = '',
    this.description = '',
    this.rating = 4.7,
    this.deliveryTime = '20 min',
  });

  @override
  _RestaurantViewScreenState createState() => _RestaurantViewScreenState();
}

class _RestaurantViewScreenState extends State<RestaurantViewScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedCategory = 'Burger';

  final List<String> categories = ['Burger', 'Sandwich', 'Pizza', 'Sandwich'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.black87),
                    ),
                  ),
                  // Title
                  Text(
                    'Restaurant View',
                    style: TextStyle(
                      fontFamily: 'Sen',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  // Cart Icon with Badge
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(0xFF1A1B2E),
                          shape: BoxShape.circle,
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

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Image
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFB0BEC5),
                          borderRadius: BorderRadius.circular(20),
                          image: widget.restaurantImage.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(widget.restaurantImage),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: widget.restaurantImage.isEmpty
                            ? Center(
                                child: Icon(
                                  Icons.restaurant_menu,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              )
                            : null,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Restaurant Name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        widget.restaurantName,
                        style: TextStyle(
                          fontFamily: 'Sen',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        widget.description.isNotEmpty
                            ? widget.description
                            : 'Maecenas sed diam eget risus varius blandit sit amet non magna. Integer posuere erat a ante venenatis dapibus posuere velit aliquet.',
                        style: TextStyle(
                          fontFamily: 'Sen',
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Rating and Delivery Time
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 24),
                          SizedBox(width: 6),
                          Text(
                            widget.rating.toString(),
                            style: TextStyle(
                              fontFamily: 'Sen',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 20),
                          Icon(Icons.access_time, color: Colors.orange, size: 24),
                          SizedBox(width: 6),
                          Text(
                            widget.deliveryTime,
                            style: TextStyle(
                              fontFamily: 'Sen',
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Category Chips
                    Container(
                      height: 50,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = selectedCategory == category;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 12),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.orange : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isSelected ? Colors.orange : Color(0xFFE0E0E0),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontFamily: 'Sen',
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 24),

                    // Category Title with Count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        '$selectedCategory (10)',
                        style: TextStyle(
                          fontFamily: 'Sen',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Menu Items Grid
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('restaurants')
                          .doc(widget.restaurantId)
                          .collection('menu')
                          .where('category', isEqualTo: selectedCategory)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Error loading menu'));
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: CircularProgressIndicator(color: Colors.orange),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(Icons.restaurant_menu, size: 48, color: Colors.grey),
                                  SizedBox(height: 12),
                                  Text(
                                    'No items in this category',
                                    style: TextStyle(
                                      fontFamily: 'Sen',
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.68,
                            ),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var doc = snapshot.data!.docs[index];
                              var menuItem = doc.data() as Map<String, dynamic>;
                              
                              return MenuItemCard(
                                itemId: doc.id,
                                name: menuItem['name'] ?? 'Item',
                                restaurantName: menuItem['restaurantName'] ?? widget.restaurantName,
                                price: menuItem['price'] ?? 0,
                                imageUrl: menuItem['imageUrl'] ?? '',
                                description: menuItem['description'] ?? '',
                                rating: widget.rating,
                                deliveryTime: widget.deliveryTime,
                                onTap: () {
                                  // Navigate to item details
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetailsScreen(
                                        itemId: doc.id,
                                        itemName: menuItem['name'] ?? 'Item',
                                        restaurantName: menuItem['restaurantName'] ?? widget.restaurantName,
                                        imageUrl: menuItem['imageUrl'] ?? '',
                                        description: menuItem['description'] ?? '',
                                        price: menuItem['price'] ?? 0,
                                        rating: widget.rating,
                                        deliveryTime: widget.deliveryTime,
                                      ),
                                    ),
                                  );
                                },
                                onAddToCart: () {
                                  // Quick add to cart
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${menuItem['name']} added to cart!'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final String itemId;
  final String name;
  final String restaurantName;
  final int price;
  final String imageUrl;
  final String description;
  final double rating;
  final String deliveryTime;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const MenuItemCard({
    required this.itemId,
    required this.name,
    required this.restaurantName,
    required this.price,
    this.imageUrl = '',
    this.description = '',
    this.rating = 4.7,
    this.deliveryTime = '20 min',
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFB0BEC5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                        Icons.fastfood,
                        size: 40,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    )
                  : null,
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Item Name
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Sen',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  // Restaurant Name
                  Text(
                    restaurantName,
                    style: TextStyle(
                      fontFamily: 'Sen',
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  // Price and Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '$price Kč',
                          style: TextStyle(
                            fontFamily: 'Sen',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}