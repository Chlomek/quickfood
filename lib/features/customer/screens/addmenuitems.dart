import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addTestMenuItems(String restaurantId) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Map<String, dynamic>> menuItems = [
    {
      'name': 'Burger Ferguson',
      'category': 'Burger',
      'price': 330,
      'restaurantName': 'Spicy Restaurant',
      'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
    },
    {
      'name': 'Rockin\' Burgers',
      'category': 'Burger',
      'price': 400,
      'restaurantName': 'Cafecafachino',
      'imageUrl': 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500',
    },
    {
      'name': 'Classic Burger',
      'category': 'Burger',
      'price': 500,
      'restaurantName': 'Spicy Restaurant',
      'imageUrl': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500',
    },
    {
      'name': 'Cheese Delight',
      'category': 'Burger',
      'price': 220,
      'restaurantName': 'Cafecafachino',
      'imageUrl': 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500',
    },
    {
      'name': 'Margherita Pizza',
      'category': 'Pizza',
      'price': 450,
      'restaurantName': 'Spicy Restaurant',
      'imageUrl': 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500',
    },
    {
      'name': 'Pepperoni Pizza',
      'category': 'Pizza',
      'price': 520,
      'restaurantName': 'Spicy Restaurant',
      'imageUrl': 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500',
    },
    {
      'name': 'Club Sandwich',
      'category': 'Sandwich',
      'price': 280,
      'restaurantName': 'Spicy Restaurant',
      'imageUrl': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=500',
    },
    {
      'name': 'Veggie Sandwich',
      'category': 'Sandwich',
      'price': 250,
      'restaurantName': 'Spicy Restaurant',
      'imageUrl': 'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=500',
    },
  ];

  for (var item in menuItems) {
    await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menu')
        .add(item);
  }
  
  print('Test menu items added!');
}

// Usage: Call with your restaurant ID
// addTestMenuItems('your-restaurant-id-here');