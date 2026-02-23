import 'package:flutter/material.dart';
import '../screens/restaurantviewscreen.dart';

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
