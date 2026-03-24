import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quickfood/features/shared/services/order_model.dart';
import 'package:quickfood/features/shared/services/order_service.dart'; // Make sure this path is correct!

// Export the model so any file importing this provider also gets the model
export 'package:quickfood/features/shared/services/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  List<Order> _orders = [];
  bool _isLoading = false;
  StreamSubscription? _ordersSubscription;

  // Getters
  List<Order> get orders => [..._orders];
  
  // An order is active if it is pending, confirmed, preparing, or ready
  List<Order> get activeOrders => _orders.where((order) => 
      order.status == OrderStatus.pending ||
      order.status == OrderStatus.restaurantConfirmed ||
      order.status == OrderStatus.preparing ||
      order.status == OrderStatus.ready).toList();
      
  List<Order> get completedOrders => _orders.where((order) => 
      order.status == OrderStatus.completed || 
      order.status == OrderStatus.cancelled).toList();
  
  int get activeOrdersCount => activeOrders.length;
  bool get hasActiveOrder => activeOrders.isNotEmpty;
  bool get isLoading => _isLoading;

  OrderProvider() {
    _initStream();
  }

  // Automatically listen to Firestore changes
  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _ordersSubscription = _orderService.watchUserOrders().listen(
      (orderList) {
        _orders = orderList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Error in order stream: $error");
        _isLoading = false;
        notifyListeners();
      }
    );
  }

  // Fallback for manual refresh if needed (e.g., Pull to Refresh)
  Future<void> loadOrders() async {
    // The stream handles automatic updates, but we can keep this for the RefreshIndicator
    notifyListeners(); 
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}