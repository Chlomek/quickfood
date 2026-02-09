import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addTestRestaurants() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Map<String, dynamic>> restaurants = [
    {
      'name': 'Rose Garden Restaurant',
      'categories': 'Burger - Chicken - Riche - Wings',
      'rating': 4.7,
      'deliveryTime': '20 min',
      'imageUrl': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500',
    },
    {
      'name': 'Pizza Paradise',
      'categories': 'Pizza - Italian - Pasta',
      'rating': 4.5,
      'deliveryTime': '25 min',
      'imageUrl': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
    },
    {
      'name': 'Burger House',
      'categories': 'Burger - Fries - American',
      'rating': 4.8,
      'deliveryTime': '15 min',
      'imageUrl': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500',
    },
    {
      'name': 'Sushi Station',
      'categories': 'Sushi - Japanese - Seafood',
      'rating': 4.9,
      'deliveryTime': '30 min',
      'imageUrl': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500',
    },
  ];

  for (var restaurant in restaurants) {
    await _firestore.collection('restaurants').add(restaurant);
  }
  
  print('Test restaurants added!');
}