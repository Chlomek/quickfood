import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartItem {
  final String id;
  final String name;
  final int price;
  final String imageUrl;
  final String restaurantName;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.restaurantName,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'restaurantName': restaurantName,
    'quantity': quantity,
  };

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: map['price'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, CartItem> get items => {..._items};
  
  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);
  
  int get totalPrice => _items.values.fold(0, (sum, item) => sum + (item.price * item.quantity));

  String? get currentRestaurant => _items.isEmpty ? null : _items.values.first.restaurantName;

  // Load cart from Firestore
  Future<void> loadCart() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final cartSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .get();

      _items.clear();
      for (var doc in cartSnapshot.docs) {
        final item = CartItem.fromMap(doc.data());
        _items[item.id] = item;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading cart: $e');
    }
  }

  // Add item to cart
  Future<void> addToCart(CartItem newItem) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("Please log in to add items to cart");
    }

    // SAFETY CHECK: Ensure same restaurant
    if (_items.isNotEmpty && _items.values.first.restaurantName != newItem.restaurantName) {
      throw Exception("You can only order from one restaurant at a time. Clear your cart from ${_items.values.first.restaurantName} first!");
    }

    try {
      // Local Update
      if (_items.containsKey(newItem.id)) {
        _items.update(newItem.id, (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          imageUrl: existing.imageUrl,
          restaurantName: existing.restaurantName,
          quantity: existing.quantity + newItem.quantity,
        ));
      } else {
        _items[newItem.id] = newItem;
      }
      notifyListeners();

      // Sync to Firestore
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(newItem.id)
          .set(_items[newItem.id]!.toMap());
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  // Increment quantity
  Future<void> incrementQuantity(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    if (_items.containsKey(id)) {
      // Prevent excessive quantity
      if (_items[id]!.quantity >= 99) return;

      _items[id]!.quantity++;
      notifyListeners();

      // Sync to Firestore
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('cart')
            .doc(id)
            .update({'quantity': _items[id]!.quantity});
      } catch (e) {
        print('Error incrementing quantity: $e');
      }
    }
  }

  // Decrement quantity
  Future<void> decrementQuantity(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    if (_items.containsKey(id)) {
      if (_items[id]!.quantity > 1) {
        _items[id]!.quantity--;
        notifyListeners();

        // Sync to Firestore
        try {
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('cart')
              .doc(id)
              .update({'quantity': _items[id]!.quantity});
        } catch (e) {
          print('Error decrementing quantity: $e');
        }
      } else {
        // If quantity is 1, remove the item instead
        await removeItem(id);
      }
    }
  }

  // Remove single item from cart
  Future<void> removeItem(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    if (_items.containsKey(id)) {
      // Local update
      _items.remove(id);
      notifyListeners();

      // Sync to Firestore
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('cart')
            .doc(id)
            .delete();
      } catch (e) {
        print('Error removing item: $e');
      }
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // Get all cart items
      final cartSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .get();

      // Delete all items in Firestore
      final batch = _firestore.batch();
      for (var doc in cartSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Clear local cart
      _items.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  // Check if item is in cart
  bool isInCart(String id) {
    return _items.containsKey(id);
  }

  // Get quantity of specific item
  int getItemQuantity(String id) {
    return _items.containsKey(id) ? _items[id]!.quantity : 0;
  }

  // Update item quantity directly
  Future<void> updateQuantity(String id, int newQuantity) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    if (_items.containsKey(id)) {
      if (newQuantity <= 0) {
        await removeItem(id);
        return;
      }

      if (newQuantity > 99) {
        newQuantity = 99; // Max quantity limit
      }

      _items[id]!.quantity = newQuantity;
      notifyListeners();

      // Sync to Firestore
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('cart')
            .doc(id)
            .update({'quantity': newQuantity});
      } catch (e) {
        print('Error updating quantity: $e');
      }
    }
  }
}