import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared/services/order_service.dart';
import '../../shared/services/order_model.dart';
import 'addnewitemscreen.dart';
import 'restaurantmenu.dart';
import 'restaurantordersscreen.dart';
import 'restaurantprofilesetupscreen.dart';
import '../../shared/screens/profilesettingsscreen.dart';
import '../widgets/restaurant_drawer_menu.dart';
import '../widgets/restaurant_bottom_navbar.dart';

class RestaurantHomeScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantHomeScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantHomeScreen> createState() => _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends State<RestaurantHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OrderService _orderService = OrderService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isOpen = false;
  bool _loadingToggle = false;
  int _selectedNavIndex = 0;
  final Set<String> _updatingOrderIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadIsOpen();
  }

  Future<void> _loadIsOpen() async {
    final doc = await _firestore
        .collection('restaurants')
        .doc(widget.restaurantId)
        .get();
    if (doc.exists && mounted) {
      setState(() {
        _isOpen = (doc.data() as Map<String, dynamic>)['isOpen'] ?? false;
      });
    }
  }

  Future<void> _toggleOpen() async {
    if (_loadingToggle) return;

    final action = _isOpen ? 'close' : 'open';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${_isOpen ? 'Close' : 'Open'} Restaurant'),
        content: Text('Are you sure you want to $action your restaurant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              _isOpen ? 'Close' : 'Open',
              style: const TextStyle(color: Color(0xFFFF6B35)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loadingToggle = true);
    try {
      final newValue = !_isOpen;
      await _firestore
          .collection('restaurants')
          .doc(widget.restaurantId)
          .update({'isOpen': newValue});
      setState(() => _isOpen = newValue);
    } finally {
      setState(() => _loadingToggle = false);
    }
  }

  Future<void> _updateOrderStatus(
    BuildContext context,
    String orderId,
    OrderStatus status,
  ) async {
    if (_updatingOrderIds.contains(orderId)) return;

    setState(() => _updatingOrderIds.add(orderId));
    try {
      await _orderService.updateStatus(orderId, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order updated to ${status.firestoreValue}'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingOrderIds.remove(orderId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<List<Order>>(
                stream: _orderService.watchRestaurantOrders(
                  widget.restaurantId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B35),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load orders: ${snapshot.error}',
                        style: const TextStyle(
                          fontFamily: 'Sen',
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  final orders = snapshot.data ?? [];
                  final activeOrders = orders
                      .where(
                        (o) =>
                            o.status == OrderStatus.restaurantConfirmed ||
                            o.status == OrderStatus.preparing ||
                            o.status == OrderStatus.ready,
                      )
                      .toList();
                  final pendingOrders = orders
                      .where((o) => o.status == OrderStatus.pending)
                      .toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Stats row ──
                        _buildStatsRow(
                          activeOrders.length,
                          pendingOrders.length,
                        ),
                        const SizedBox(height: 28),

                        // ── Running orders ──
                        if (activeOrders.isNotEmpty) ...[
                          _buildSectionLabel('RUNNING ORDERS'),
                          const SizedBox(height: 12),
                          ...activeOrders.map((o) => _buildRunningOrderCard(o)),
                          const SizedBox(height: 28),
                        ],

                        // ── New order banners ──
                        ...pendingOrders.map((o) => _buildNewOrderBanner(o)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: const Color(0xFFF4F6FA),
      child: Row(
        children: [
          // Menu icon
          GestureDetector(
            onTap: () => _showRestaurantMenu(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.menu, size: 20, color: Color(0xFF2D2D2D)),
            ),
          ),

          // Location
          Expanded(
            child: Column(
              children: [
                const Text(
                  'LOCATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Color(0xFFFF6B35),
                    fontFamily: 'Sen',
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'My Restaurant',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        fontFamily: 'Sen',
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: Color(0xFF1A1A2E),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Open/closed toggle avatar
          GestureDetector(
            onTap: _toggleOpen,
            child: Stack(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isOpen
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFBDBDBD),
                    boxShadow: [
                      BoxShadow(
                        color: (_isOpen ? const Color(0xFF4CAF50) : Colors.grey)
                            .withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: _loadingToggle
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _isOpen
                              ? Icons.storefront
                              : Icons.store_mall_directory_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isOpen
                          ? const Color(0xFF00E676)
                          : const Color(0xFFFF5252),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow(int running, int requests) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: running.toString().padLeft(2, '0'),
            label: 'RUNNING ORDERS',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            value: requests.toString().padLeft(2, '0'),
            label: 'ORDER REQUESTS',
            accent: requests > 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    bool accent = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              height: 1,
              color: accent ? const Color(0xFFFF6B35) : const Color(0xFF1A1A2E),
              fontFamily: 'Sen',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF9E9E9E),
              fontFamily: 'Sen',
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.8,
        color: Color(0xFF9E9E9E),
        fontFamily: 'Sen',
      ),
    );
  }

  // ── Running order card ────────────────────────────────────────────────────

  Widget _buildRunningOrderCard(Order order) {
    final showAllItems = order.status == OrderStatus.preparing;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                order.items.isNotEmpty && order.items.first.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      order.items.first.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.fastfood,
                    color: Color(0xFFBDBDBD),
                    size: 32,
                  ),
          ),
          const SizedBox(width: 18),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  Text(
                    '#${order.items.isNotEmpty ? order.items.first.name.split(" ").first : "Order"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Sen',
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Item names
                  if (showAllItems && order.items.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: order.items
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                '${item.quantity}x ${item.name}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                  fontFamily: 'Sen',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                    )
                  else
                    Text(
                      order.items.length == 1
                          ? order.items.first.name
                          : '${order.items.first.name} +${order.items.length - 1}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        fontFamily: 'Sen',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${order.id.substring(0, 6).toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                      fontFamily: 'Sen',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price + action buttons (responsive to avoid right overflow)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final actionButtons = _buildRunningActionButtons(
                        context,
                        order,
                      );
                      final compact = constraints.maxWidth < 230;

                      if (actionButtons.isEmpty) {
                        return Text(
                          '${order.total} Kč',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            fontFamily: 'Sen',
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order.total} Kč',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                              fontFamily: 'Sen',
                            ),
                          ),
                          SizedBox(height: compact ? 8 : 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.end,
                              children: actionButtons,
                            ),
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

  List<Widget> _buildRunningActionButtons(BuildContext context, Order order) {
    final isUpdating = _updatingOrderIds.contains(order.id);

    switch (order.status) {
      case OrderStatus.restaurantConfirmed:
        return [
          _outlineBtn(
            isUpdating ? '...' : 'Preparing',
            isUpdating
                ? null
                : () => _updateOrderStatus(
                    context,
                    order.id,
                    OrderStatus.preparing,
                  ),
          ),
          _outlineBtn(
            isUpdating ? '...' : 'Cancel',
            isUpdating
                ? null
                : () => _updateOrderStatus(
                    context,
                    order.id,
                    OrderStatus.cancelled,
                  ),
            color: Colors.red,
          ),
        ];
      case OrderStatus.preparing:
        return [
          _outlineBtn(
            isUpdating ? '...' : 'Ready',
            isUpdating
                ? null
                : () =>
                      _updateOrderStatus(context, order.id, OrderStatus.ready),
            color: const Color(0xFFFF6B35),
          ),
          _outlineBtn(
            isUpdating ? '...' : 'Cancel',
            isUpdating
                ? null
                : () => _updateOrderStatus(
                    context,
                    order.id,
                    OrderStatus.cancelled,
                  ),
            color: Colors.red,
          ),
        ];
      case OrderStatus.ready:
        return [
          _filledBtn(
            isUpdating ? '...' : 'Done',
            isUpdating
                ? null
                : () => _updateOrderStatus(
                    context,
                    order.id,
                    OrderStatus.completed,
                  ),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _outlineBtn(
    String label,
    VoidCallback? onTap, {
    Color color = const Color(0xFF1A1A2E),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: onTap == null ? Colors.grey : color,
            fontFamily: 'Sen',
          ),
        ),
      ),
    );
  }

  Widget _filledBtn(String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: onTap == null
              ? const Color(0xFFBDBDBD)
              : const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Sen',
          ),
        ),
      ),
    );
  }

  // ── New order banner ──────────────────────────────────────────────────────

  Widget _buildNewOrderBanner(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Orange "YOU HAVE NEW ORDER" bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B35),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: const Text(
              'YOU HAVE A NEW ORDER',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: Colors.white,
                fontFamily: 'Sen',
              ),
            ),
          ),

          // Order items
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              children: order.items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF0F5),
                              borderRadius: BorderRadius.circular(12),
                              image: item.imageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(item.imageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: item.imageUrl.isEmpty
                                ? const Icon(
                                    Icons.fastfood,
                                    color: Color(0xFFBDBDBD),
                                    size: 28,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E),
                                    fontFamily: 'Sen',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.price} Kč',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E),
                                    fontFamily: 'Sen',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF0F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.quantity}x',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                                fontFamily: 'Sen',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),

          // Total + Order ID
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${order.total} Kč',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    fontFamily: 'Sen',
                  ),
                ),
                Text(
                  'Order #${order.id.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E9E9E),
                    fontFamily: 'Sen',
                  ),
                ),
              ],
            ),
          ),

          // Accept / Reject buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                // Reject
                Expanded(
                  child: GestureDetector(
                    onTap: _updatingOrderIds.contains(order.id)
                        ? null
                        : () => _updateOrderStatus(
                            context,
                            order.id,
                            OrderStatus.cancelled,
                          ),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFEBEE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Reject Order',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            fontFamily: 'Sen',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Accept
                Expanded(
                  child: GestureDetector(
                    onTap: _updatingOrderIds.contains(order.id)
                        ? null
                        : () => _updateOrderStatus(
                            context,
                            order.id,
                            OrderStatus.restaurantConfirmed,
                          ),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFF4CAF50),
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Accept Order',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            fontFamily: 'Sen',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return RestaurantBottomNavBar(
      selectedIndex: _selectedNavIndex,
      onHomeTap: () => setState(() => _selectedNavIndex = 0),
      onCenterTap: () async {
        final added = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => AddNewItemScreen(restaurantId: widget.restaurantId),
          ),
        );

        if (added == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Menu refreshed with new item'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      onMenuTap: () {
        setState(() => _selectedNavIndex = 2);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RestaurantMenuScreen(restaurantId: widget.restaurantId),
          ),
        );
      },
    );
  }

  Future<void> _showRestaurantMenu(BuildContext context) async {
    final user = _auth.currentUser;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return RestaurantDrawerMenu(
          user: user,
          isOpen: _isOpen,
          onDashboardTap: () => Navigator.pop(sheetContext),
          onToggleOpenTap: () async {
            Navigator.pop(sheetContext);
            await _toggleOpen();
          },
          onOrderHistoryTap: () {
            Navigator.pop(sheetContext);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    RestaurantOrdersScreen(restaurantId: widget.restaurantId),
              ),
            );
          },
          onRestaurantProfileTap: () {
            Navigator.pop(sheetContext);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RestaurantProfileSetupScreen(
                  userId: _auth.currentUser!.uid,
                  restaurantId: widget.restaurantId,
                  navigateToHomeOnSave: false,
                ),
              ),
            );
          },
          onSettingsTap: () {
            Navigator.pop(sheetContext);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
            );
          },
          onLogoutTap: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (shouldLogout == true) {
              Navigator.pop(sheetContext);
              await _auth.signOut();
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            }
          },
        );
      },
    );
  }
}
