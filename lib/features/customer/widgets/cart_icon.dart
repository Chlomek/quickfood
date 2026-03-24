import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickfood/features/shared/services/cartProvider.dart';
import 'package:quickfood/features/shared/services/order_provider.dart';
import 'package:quickfood/features/customer/screens/cartscreen.dart';
import 'package:quickfood/features/shared/services/order_model.dart';
import 'package:quickfood/features/customer/screens/orderstatusscreen.dart';

class CartBadgeIcon extends StatelessWidget {
  const CartBadgeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, OrderProvider>(
      builder: (context, cart, orderProvider, child) {
        // If there's an active order, show Orders icon instead of Cart
        if (orderProvider.hasActiveOrder) {
          final activeOrder = orderProvider.activeOrders.first;
          return _buildOrdersIcon(context, activeOrder);
        }

        // Otherwise, show Cart icon
        return _buildCartIcon(context, cart);
      },
    );
  }

  // Cart Icon Widget
  Widget _buildCartIcon(BuildContext context, CartProvider cart) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
      },
      child: Stack(
        children: [
          // The Circular Bag Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1B2E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          // The Dynamic Orange Badge
          if (cart.itemCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    '${cart.itemCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Sen',
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Orders Icon Widget
  Widget _buildOrdersIcon(BuildContext context, Order activeOrder) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderStatusScreen(
              orderId: activeOrder.id,
              restaurantName: activeOrder.restaurantName,
              items: activeOrder.items,
              totalPrice: activeOrder.total,
              currentStatus: activeOrder.status,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          // The Circular Receipt Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1B2E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          // Active order badge
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: const Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sen',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}