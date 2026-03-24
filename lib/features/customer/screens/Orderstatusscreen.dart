import 'package:flutter/material.dart';
import 'package:quickfood/features/shared/services/order_model.dart'; // 1. Using the real global model
import 'package:quickfood/features/shared/services/order_service.dart';

class OrderStatusScreen extends StatelessWidget {
  final String orderId;
  final String restaurantName;
  final List<OrderItem> items; // Now using the OrderItem from order_model.dart
  final int totalPrice;
  final OrderStatus currentStatus; // 2. Using your real OrderStatus enum
  final OrderService _orderService = OrderService();

  OrderStatusScreen({
    super.key,
    required this.orderId,
    required this.restaurantName,
    required this.items,
    required this.totalPrice,
    // Default to pending, which matches the start of your lifecycle
    this.currentStatus = OrderStatus.pending, 
  });

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF1C1C2E);
    const Color cardColor = Color(0xFF2A2A3E);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.1),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Order Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Order Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildOrderItem(item, cardColor);
              },
            ),
          ),

          // Bottom Order Summary
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Name
                  const Text(
                    'RESTAURANT',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      restaurantName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5A6C7D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Total Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$totalPrice Kč',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Order Status Title
                  const Text(
                    'ORDER STATUS:',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Listen to order document so status updates in real time.
                  StreamBuilder<OrderStatus>(
                    stream: _orderService.watchOrderStatus(orderId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(
                          'Status unavailable: ${snapshot.error}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        );
                      }

                      final liveStatus = snapshot.data ?? currentStatus;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current: ${_statusLabel(liveStatus)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatusStep(
                                'Confirmed',
                                OrderStatus.restaurantConfirmed,
                                liveStatus,
                              ),
                              _buildStatusConnector(
                                liveStatus.index >= OrderStatus.preparing.index,
                              ),
                              _buildStatusStep(
                                'Preparing\nYour Order',
                                OrderStatus.preparing,
                                liveStatus,
                              ),
                              _buildStatusConnector(
                                liveStatus.index >= OrderStatus.ready.index,
                              ),
                              _buildStatusStep(
                                'Ready For\nPickup',
                                OrderStatus.ready,
                                liveStatus,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Item Image
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              image: item.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.imageUrl.isEmpty
                ? Icon(
                    Icons.fastfood,
                    size: 36,
                    color: Colors.white.withOpacity(0.3),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Removed item.category since your global OrderItem doesn't use it
                // Instead, showing price per unit if they order multiple
                Text(
                  '${item.price} Kč each',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  // 4. Using the subtotal getter from your model
                  '${item.subtotal} Kč', 
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Quantity
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${item.quantity} Pcs',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.restaurantConfirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready For Pickup';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // 5. Updated to use OrderStatus instead of OrderStatusEnum
  Widget _buildStatusStep(String label, OrderStatus stepStatus, OrderStatus currentStatus) {
    // A step is complete if the current status index is >= the step's index
    final isCompleted = currentStatus.index >= stepStatus.index;
    final accentColor = _stepColor(stepStatus);
    final stepIcon = _stepIcon(stepStatus);
    
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isCompleted
                ? accentColor
                : accentColor.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isCompleted ? Icons.check : stepIcon,
            color: isCompleted ? Colors.white : accentColor,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isCompleted ? accentColor : Colors.grey.shade600,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Color _stepColor(OrderStatus stepStatus) {
    switch (stepStatus) {
      case OrderStatus.restaurantConfirmed:
        return const Color(0xFF3B82F6);
      case OrderStatus.preparing:
        return const Color(0xFFF59E0B);
      case OrderStatus.ready:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  IconData _stepIcon(OrderStatus stepStatus) {
    switch (stepStatus) {
      case OrderStatus.restaurantConfirmed:
        return Icons.storefront_outlined;
      case OrderStatus.preparing:
        return Icons.restaurant_menu;
      case OrderStatus.ready:
        return Icons.inventory_2_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _buildStatusConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 50),
        color: isActive ? const Color(0xFFD1D5DB) : const Color(0xFFE5E7EB),
      ),
    );
  }
}