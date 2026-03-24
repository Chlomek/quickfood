import 'package:flutter/material.dart';

class OrderStatusScreen extends StatelessWidget {
  final String orderId;
  final String restaurantName;
  final List<OrderItem> items;
  final int totalPrice;
  final OrderStatusEnum currentStatus;

  const OrderStatusScreen({
    super.key,
    required this.orderId,
    required this.restaurantName,
    required this.items,
    required this.totalPrice,
    this.currentStatus = OrderStatusEnum.restaurantConfirmed,
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

                  // Order Status Timeline
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusStep(
                        'Restaurant\nConfirmed',
                        OrderStatusEnum.restaurantConfirmed,
                        currentStatus,
                      ),
                      _buildStatusConnector(
                        currentStatus.index >= OrderStatusEnum.preparing.index,
                      ),
                      _buildStatusStep(
                        'Preparing\nYour Order',
                        OrderStatusEnum.preparing,
                        currentStatus,
                      ),
                      _buildStatusConnector(
                        currentStatus.index >= OrderStatusEnum.readyForPickup.index,
                      ),
                      _buildStatusStep(
                        'Ready For\nPickup',
                        OrderStatusEnum.readyForPickup,
                        currentStatus,
                      ),
                    ],
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
                Text(
                  item.category,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.price} Kč',
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

  Widget _buildStatusStep(String label, OrderStatusEnum stepStatus, OrderStatusEnum currentStatus) {
    final isCompleted = currentStatus.index >= stepStatus.index;
    
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isCompleted 
                ? const Color(0xFFD1D5DB) 
                : const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: isCompleted ? Colors.white : const Color(0xFFD1D5DB),
            size: 32,
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
              color: isCompleted ? Colors.black87 : Colors.grey,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
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

// Renamed enum to avoid conflict with OrderProvider's OrderStatus
enum OrderStatusEnum {
  restaurantConfirmed,
  preparing,
  readyForPickup,
  completed,
}

// Order Item Model
class OrderItem {
  final String name;
  final String category;
  final int price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    this.imageUrl = '',
  });
}