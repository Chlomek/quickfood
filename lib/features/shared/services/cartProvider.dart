import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'order_service.dart';

// ── CartItem ──────────────────────────────────────────────────────────────────

class CartItem {
  final String id;                  // same as menuItemId — used as map key
  final String menuItemId;
  final String name;
  final int price;                  // snapshotted at add-time, never changes
  final String imageUrl;
  final int quantity;

  const CartItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  int get subtotal => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        menuItemId: menuItemId,
        name: name,
        price: price,
        imageUrl: imageUrl,
        quantity: quantity ?? this.quantity,
      );

  // Serialize for Firestore order document
  Map<String, dynamic> toOrderMap() => {
    'menuItemId': menuItemId,
    'name': name,
    'price': price,
    'quantity': quantity,
    'subtotal': subtotal,
    'imageUrl': imageUrl,
  };
}

// ── CartStatus ────────────────────────────────────────────────────────────────

enum CartStatus {
  empty,        // no items
  active,       // has items, restaurant is open
  closed,       // has items but restaurant is closed — checkout blocked
  submitting,   // order write in progress
  error,        // order write failed — cart preserved
}

// ── CartProvider ──────────────────────────────────────────────────────────────

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OrderService _orderService = OrderService();

  // ── Internal state ────────────────────────────────────────────────────────

  String? _restaurantId;
  String? _restaurantName;

  // Map keyed by menuItemId for O(1) lookup — CartScreen uses .values
  final Map<String, CartItem> _items = {};

  bool _restaurantIsOpen = true;
  StreamSubscription<DocumentSnapshot>? _restaurantListener;

  CartStatus _status = CartStatus.empty;
  String? _errorMessage;
  String? _lastOrderId;   // set after successful checkout

  // ── Getters (matching CartScreen's expectations) ──────────────────────────

  /// CartScreen uses cart.items.values.toList()
  Map<String, CartItem> get items => Map.unmodifiable(_items);

  /// CartScreen uses cart.currentRestaurant
  String? get currentRestaurant => _restaurantName;

  /// CartScreen uses cart.totalPrice
  int get totalPrice => _items.values.fold(0, (sum, i) => sum + i.subtotal);

  // Extra getters
  String? get restaurantId => _restaurantId;
  bool get restaurantIsOpen => _restaurantIsOpen;
  CartStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get lastOrderId => _lastOrderId;

  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.values.fold(0, (sum, i) => sum + i.quantity);

  bool get canCheckout =>
      !isEmpty && _restaurantIsOpen && _status != CartStatus.submitting;

  // ── Add item ──────────────────────────────────────────────────────────────

  /// [onConflict] receives the current restaurant name and should show a dialog.
  /// Return true to clear cart and switch, false to cancel.
  Future<bool> addItem({
    required CartItem item,
    required String restaurantId,
    required String restaurantName,
    required Future<bool> Function(String currentRestaurantName) onConflict,
  }) async {
    // Conflict — different restaurant already in cart
    if (_restaurantId != null && _restaurantId != restaurantId) {
      final confirmed = await onConflict(_restaurantName!);
      if (!confirmed) return false;
      _clearCart();
    }

    // First item — bind to restaurant and start isOpen listener
    if (_restaurantId == null) {
      _restaurantId = restaurantId;
      _restaurantName = restaurantName;
      _startRestaurantListener(restaurantId);
    }

    // Increment existing or add new line
    if (_items.containsKey(item.menuItemId)) {
      _items[item.menuItemId] = _items[item.menuItemId]!.copyWith(
        quantity: _items[item.menuItemId]!.quantity + 1,
      );
    } else {
      _items[item.menuItemId] = item;
    }

    _updateStatus();
    notifyListeners();
    return true;
  }

  // ── Increment / decrement (CartScreen's +/- buttons) ─────────────────────

  void incrementQuantity(String menuItemId) {
    if (!_items.containsKey(menuItemId)) return;
    _items[menuItemId] = _items[menuItemId]!.copyWith(
      quantity: _items[menuItemId]!.quantity + 1,
    );
    _updateStatus();
    notifyListeners();
  }

  void decrementQuantity(String menuItemId) {
    if (!_items.containsKey(menuItemId)) return;
    final current = _items[menuItemId]!.quantity;
    if (current <= 1) {
      removeItem(menuItemId);
      return;
    }
    _items[menuItemId] = _items[menuItemId]!.copyWith(quantity: current - 1);
    _updateStatus();
    notifyListeners();
  }

  // ── Remove entire line ────────────────────────────────────────────────────

  /// CartScreen calls cart.removeItem(item.id)
  Future<void> removeItem(String menuItemId) async {
    _items.remove(menuItemId);
    if (_items.isEmpty) _clearCart();
    _updateStatus();
    notifyListeners();
  }

  // ── Clear entire cart ─────────────────────────────────────────────────────

  Future<void> clearCart() async {
    _clearCart();
    notifyListeners();
  }

  // ── Checkout / place order ────────────────────────────────────────────────

  /// Returns the new order ID on success, null on failure.
  /// CartScreen should call this and navigate on non-null result.
  Future<String?> placeOrder() async {
    if (!canCheckout) return null;

    _status = CartStatus.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final orderId = await _orderService.placeOrder(
        restaurantId: _restaurantId!,
        restaurantName: _restaurantName!,
        items: _items.values.map((i) => i.toOrderMap()).toList(),
        total: totalPrice,
      );

      _lastOrderId = orderId;

      // Only clear cart after confirmed Firestore write
      _clearCart();
      _status = CartStatus.empty;
      notifyListeners();
      return orderId;

    } catch (e) {
      // Preserve cart so user doesn't lose their items
      _status = CartStatus.error;
      _errorMessage = 'Failed to place order. Please try again.';
      notifyListeners();
      return null;
    }
  }

  // ── Convenience: quantity of one item (for menu screen +/- display) ───────

  int quantityOf(String menuItemId) => _items[menuItemId]?.quantity ?? 0;

  // ── Restaurant open/closed listener ───────────────────────────────────────

  void _startRestaurantListener(String restaurantId) {
    _restaurantListener?.cancel();
    _restaurantListener = _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) {
        _restaurantIsOpen = false;
      } else {
        final data = doc.data() as Map<String, dynamic>;
        _restaurantIsOpen = data['isOpen'] ?? true;
      }
      _updateStatus();
      notifyListeners();
    });
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  void _updateStatus() {
    if (_items.isEmpty) {
      _status = CartStatus.empty;
    } else if (_status == CartStatus.submitting || _status == CartStatus.error) {
      return; // don't interrupt in-progress states
    } else if (!_restaurantIsOpen) {
      _status = CartStatus.closed;
    } else {
      _status = CartStatus.active;
    }
  }

  void _clearCart() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    _restaurantIsOpen = true;
    _restaurantListener?.cancel();
    _restaurantListener = null;
    _status = CartStatus.empty;
    _errorMessage = null;
  }

  @override
  void dispose() {
    _restaurantListener?.cancel();
    super.dispose();
  }
}