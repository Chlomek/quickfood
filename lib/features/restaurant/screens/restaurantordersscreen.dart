import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickfood/features/customer/screens/Orderstatusscreen.dart';
import 'package:quickfood/features/shared/services/order_model.dart';
import 'package:quickfood/features/shared/services/order_service.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantOrdersScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          'Order History',
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
      body: StreamBuilder<List<Order>>(
        stream: _orderService.watchRestaurantOrders(widget.restaurantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load orders: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontFamily: 'Sen',
                  ),
                ),
              ),
            );
          }

          final orders = snapshot.data ?? [];
          final activeOrders = orders
              .where(
                (order) =>
                    order.status == OrderStatus.pending ||
                    order.status == OrderStatus.restaurantConfirmed ||
                    order.status == OrderStatus.preparing ||
                    order.status == OrderStatus.ready,
              )
              .toList();
          final historyOrders = orders
              .where(
                (order) =>
                    order.status == OrderStatus.completed ||
                    order.status == OrderStatus.cancelled,
              )
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(
                orders: activeOrders,
                emptyMessage: 'No active orders',
                emptySubMessage: 'Active restaurant orders will appear here',
              ),
              _buildOrdersList(
                orders: historyOrders,
                emptyMessage: 'No order history',
                emptySubMessage:
                    'Completed and cancelled orders will appear here',
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
  }) {
    if (orders.isEmpty) {
      return _buildEmptyState(emptyMessage, emptySubMessage);
    }

    return RefreshIndicator(
      color: Colors.orange,
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 250));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, String subMessage) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
              textAlign: TextAlign.center,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Dashboard',
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
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusInfo = _statusInfo(order.status);
    final orderNumber = order.id.length >= 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderStatusScreen(
              orderId: order.id,
              restaurantName: order.restaurantName,
              items: order.items,
              totalPrice: order.total,
              currentStatus: order.status,
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
            color: statusInfo.isActive
                ? Colors.orange.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Order #$orderNumber',
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
                _buildStatusBadge(statusInfo),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.restaurantName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'Sen',
              ),
            ),
            const SizedBox(height: 12),
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
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Text(
                  '${order.total} Kč',
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
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(_StatusInfo statusInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo.icon, size: 14, color: statusInfo.textColor),
          const SizedBox(width: 4),
          Text(
            statusInfo.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusInfo.textColor,
              fontFamily: 'Sen',
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _statusInfo(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return _StatusInfo(
          backgroundColor: Colors.orange.withOpacity(0.1),
          textColor: Colors.orange,
          label: 'Pending',
          icon: Icons.access_time,
          isActive: true,
        );
      case OrderStatus.restaurantConfirmed:
        return _StatusInfo(
          backgroundColor: Colors.blue.withOpacity(0.1),
          textColor: Colors.blue,
          label: 'Confirmed',
          icon: Icons.check_circle_outline,
          isActive: true,
        );
      case OrderStatus.preparing:
        return _StatusInfo(
          backgroundColor: Colors.purple.withOpacity(0.1),
          textColor: Colors.purple,
          label: 'Preparing',
          icon: Icons.restaurant_menu,
          isActive: true,
        );
      case OrderStatus.ready:
        return _StatusInfo(
          backgroundColor: Colors.green.withOpacity(0.1),
          textColor: Colors.green,
          label: 'Ready',
          icon: Icons.check_circle,
          isActive: true,
        );
      case OrderStatus.completed:
        return _StatusInfo(
          backgroundColor: Colors.grey.withOpacity(0.1),
          textColor: Colors.grey,
          label: 'Completed',
          icon: Icons.check_circle,
          isActive: false,
        );
      case OrderStatus.cancelled:
        return _StatusInfo(
          backgroundColor: Colors.red.withOpacity(0.1),
          textColor: Colors.red,
          label: 'Cancelled',
          icon: Icons.cancel,
          isActive: false,
        );
    }
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
}

class _StatusInfo {
  final Color backgroundColor;
  final Color textColor;
  final String label;
  final IconData icon;
  final bool isActive;

  const _StatusInfo({
    required this.backgroundColor,
    required this.textColor,
    required this.label,
    required this.icon,
    required this.isActive,
  });
}
