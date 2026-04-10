import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'addnewitemscreen.dart';
import 'restauranthomescreen.dart';
import 'restaurantordersscreen.dart';
import 'restaurantprofilesetupscreen.dart';
import '../../shared/screens/profilesettingsscreen.dart';
import '../widgets/restaurant_drawer_menu.dart';
import '../widgets/restaurant_bottom_navbar.dart';
import '../widgets/restaurant_top_header.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantMenuScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedCategory = 'All';
  bool _isOpen = false;
  bool _loadingToggle = false;
  String _restaurantName = 'My Restaurant';

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
      final data = doc.data() as Map<String, dynamic>;
      final fetchedName = (data['name'] ?? data['restaurantName'] ?? '')
          .toString()
          .trim();
      setState(() {
        _isOpen = data['isOpen'] ?? false;
        _restaurantName = fetchedName.isEmpty ? 'My Restaurant' : fetchedName;
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
      if (mounted) {
        setState(() => _isOpen = newValue);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingToggle = false);
      }
    }
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
          onDashboardTap: () {
            Navigator.pop(sheetContext);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    RestaurantHomeScreen(restaurantId: widget.restaurantId),
              ),
            );
          },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore
                    .collection('restaurants')
                    .doc(widget.restaurantId)
                    .collection('menu')
                    .snapshots(),
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
                        'Failed to load menu: ${snapshot.error}',
                        style: const TextStyle(
                          fontFamily: 'Sen',
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final categories = _extractCategories(docs);
                  final filtered = _selectedCategory == 'All'
                      ? docs
                      : docs
                            .where(
                              (d) =>
                                  (d.data()['category'] ?? '') ==
                                  _selectedCategory,
                            )
                            .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryChips(categories),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: Text(
                          'Total ${filtered.length.toString().padLeft(2, '0')} items',
                          style: const TextStyle(
                            fontFamily: 'Sen',
                            color: Color(0xFF9E9E9E),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final doc = filtered[index];
                            final data = doc.data();
                            return _buildMenuItemCard(doc.id, data);
                          },
                        ),
                      ),
                    ],
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

  Widget _buildHeader() {
    return RestaurantTopHeader(
      restaurantName: _restaurantName,
      isOpen: _isOpen,
      isLoading: _loadingToggle,
      onMenuTap: () => _showRestaurantMenu(context),
      onToggleOpenTap: _toggleOpen,
    );
  }

  List<String> _extractCategories(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final set = <String>{'All'};
    for (final doc in docs) {
      final category = (doc.data()['category'] ?? '').toString().trim();
      if (category.isNotEmpty) {
        set.add(category);
      }
    }
    return set.toList();
  }

  Widget _buildCategoryChips(List<String> categories) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFF8A1E) : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFFF8A1E)
                      : const Color(0xFFD8DAE1),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  fontFamily: 'Sen',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : const Color(0xFF2E3243),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItemCard(String menuItemId, Map<String, dynamic> item) {
    final name = (item['name'] ?? 'Menu Item').toString();
    final category = (item['category'] ?? 'General').toString();
    final price = item['price'] ?? 0;
    final imageUrl = (item['imageUrl'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: const Color(0xFF97A7B8),
              borderRadius: BorderRadius.circular(18),
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl.isEmpty
                ? const Icon(Icons.fastfood, color: Colors.white70, size: 34)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2F3A),
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddNewItemScreen(
                              restaurantId: widget.restaurantId,
                              menuItemId: menuItemId,
                              initialData: item,
                            ),
                          ),
                        );

                        if (updated == true && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item updated'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.more_horiz,
                        color: Color(0xFF2E3243),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7E1D1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontFamily: 'Sen',
                      color: Color(0xFFFF8A1E),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$price Kč',
                    style: const TextStyle(
                      fontFamily: 'Sen',
                      color: Color(0xFF2D2F3A),
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
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

  Widget _buildBottomNav() {
    return RestaurantBottomNavBar(
      selectedIndex: 2,
      onHomeTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RestaurantHomeScreen(restaurantId: widget.restaurantId),
          ),
        );
      },
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
      onMenuTap: () => _showRestaurantMenu(context),
    );
  }
}
