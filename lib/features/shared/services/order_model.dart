import 'package:cloud_firestore/cloud_firestore.dart';

// ── 1. The ONLY OrderStatus Enum ──────────────────────────────────────────────
enum OrderStatus {
  pending,
  restaurantConfirmed,
  preparing,
  ready,
  completed,
  cancelled;

  // Helper to convert to a string for Firestore
  String get firestoreValue => name;

  // Accept Firestore values in multiple formats (string/int/legacy naming).
  static OrderStatus fromFirestore(dynamic value) {
    if (value is int && value >= 0 && value < OrderStatus.values.length) {
      return OrderStatus.values[value];
    }

    if (value is! String) return OrderStatus.pending;

    return fromFirestoreValue(value);
  }

  // Helper to read the string from Firestore back into the Enum
  static OrderStatus fromFirestoreValue(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('_', '');

    switch (normalized) {
      case 'pending':
        return OrderStatus.pending;
      case 'restaurantconfirmed':
      case 'confirmed':
      case 'accepted':
        return OrderStatus.restaurantConfirmed;
      case 'preparing':
      case 'inpreparation':
      case 'inprogress':
      case 'cooking':
        return OrderStatus.preparing;
      case 'ready':
      case 'readyforpickup':
      case 'pickup':
        return OrderStatus.ready;
      case 'completed':
      case 'delivered':
      case 'done':
        return OrderStatus.completed;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

// ── 2. The ONLY OrderItem Class ───────────────────────────────────────────────
class OrderItem {
  final String menuItemId;
  final String name;
  final int price; 
  final int quantity;
  final String imageUrl;

  const OrderItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  int get subtotal => price * quantity;

  Map<String, dynamic> toMap() => {
    'menuItemId': menuItemId,
    'name': name,
    'price': price,
    'quantity': quantity,
    'subtotal': subtotal,
    'imageUrl': imageUrl,
  };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
    menuItemId: map['menuItemId'] ?? '',
    name: map['name'] ?? '',
    price: map['price'] ?? 0,
    quantity: map['quantity'] ?? 1,
    imageUrl: map['imageUrl'] ?? '',
  );
}

// ── 3. The ONLY Order Class ───────────────────────────────────────────────────
class Order {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<OrderItem> items;
  final int total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
          .toList(),
      total: data['total'] ?? 0,
      // Uses the helper method from the enum above!
      status: OrderStatus.fromFirestore(data['status'] ?? data['orderStatus']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}