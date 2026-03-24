import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:quickfood/features/shared/services/orderProvider.dart';
import 'orderstatusscreen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Refresh orders when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFF5F5F5),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Sen',
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orange,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Sen',
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            fontFamily: 'Sen',
          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Active Orders Tab
              _buildOrdersList(
                orders: orderProvider.activeOrders,
                emptyMessage: 'No active orders',
                emptySubMessage: 'Your active orders will appear here',
                isActive: true,
              ),

              // Order History Tab
              _buildOrdersList(
                orders: orderProvider.completedOrders,
                emptyMessage: 'No order history',
                emptySubMessage: 'Your completed orders will appear here',
                isActive: false,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrdersList({
    required List<Order> orders,
    required String emptyMessage,
    required String emptySubMessage,
    required bool isActive,
  }) {
    if (orders.isEmpty) {
      return _buildEmptyState(emptyMessage, emptySubMessage);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<OrderProvider>(context, listen: false).loadOrders();
      },
      color: Colors.orange,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order, isActive);
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, String subMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 100,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Sen',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subMessage,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontFamily: 'Sen',
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Browse Restaurants',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Sen',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, bool isActive) {
    return GestureDetector(
      onTap: () {
        // Navigate to Order Status Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderStatusScreen(
              orderId: order.id,
              restaurantName: order.restaurantName,
              items: order.items.map((item) {
                return OrderItem(
                  name: item['name'] ?? '',
                  category: item['category'] ?? 'Food',
                  price: item['price'] ?? 0,
                  quantity: item['quantity'] ?? 1,
                  imageUrl: item['imageUrl'] ?? '',
                );
              }).toList(),
              totalPrice: order.totalPrice,
              currentStatus: _mapOrderStatus(order.status),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? Colors.orange.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Restaurant Name & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Restaurant Name
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.restaurant,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.restaurantName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Sen',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status Badge
                _buildStatusBadge(order.status, isActive),
              ],
            ),

            const SizedBox(height: 12),

            // Order Items Count & Total Price
            Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: 'Sen',
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  '•',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${order.totalPrice} Kč',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Sen',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Timestamp
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTimestamp(order.createdAt),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: 'Sen',
                  ),
                ),
              ],
            ),

            // Order ID (for active orders only)
            if (isActive) ...[
              const SizedBox(height: 8),
              Text(
                'Order #${order.id.substring(0, 8).toUpperCase()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontFamily: 'Sen',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status, bool isActive) {
    Color backgroundColor;
    Color textColor;
    String statusText;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        statusText = 'Pending';
        icon = Icons.access_time;
        break;
      case OrderStatus.restaurantConfirmed:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        statusText = 'Confirmed';
        icon = Icons.check_circle_outline;
        break;
      case OrderStatus.preparing:
        backgroundColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        statusText = 'Preparing';
        icon = Icons.restaurant_menu;
        break;
      case OrderStatus.readyForPickup:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        statusText = 'Ready';
        icon = Icons.check_circle;
        break;
      case OrderStatus.completed:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        statusText = 'Completed';
        icon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        statusText = 'Cancelled';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'Sen',
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  // Map OrderProvider's OrderStatus to OrderStatusScreen's OrderStatus
  OrderStatusEnum _mapOrderStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.restaurantConfirmed:
        return OrderStatusEnum.restaurantConfirmed;
      case OrderStatus.preparing:
        return OrderStatusEnum.preparing;
      case OrderStatus.readyForPickup:
        return OrderStatusEnum.readyForPickup;
      case OrderStatus.completed:
        return OrderStatusEnum.readyForPickup; // Show as ready if completed
      case OrderStatus.cancelled:
        return OrderStatusEnum.restaurantConfirmed; // Default fallback
    }
  }
}

// Note: You'll need to rename the OrderStatus enum in OrderStatusScreen to avoid conflicts
// Rename it to OrderStatusEnum in orderstatusscreen.dart