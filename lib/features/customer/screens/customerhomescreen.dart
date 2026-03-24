import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/category_filter_list.dart';
import '../widgets/search_bar.dart';
import '../widgets/cart_icon.dart';

class CustomerHomeScreen extends StatefulWidget {
  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String selectedCategory = 'All';
  String searchQuery = '';
  

  static const double _expandedHeight = 205.0;

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.grid_view},
    {'name': 'Pizza', 'icon': Icons.local_pizza},
    {'name': 'Sushi', 'icon': Icons.ramen_dining},
    {'name': 'Burger', 'icon': Icons.lunch_dining},
    {'name': 'Fries', 'icon': Icons.fastfood},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _filterRestaurant(Map<String, dynamic> restaurant) {
    if (searchQuery.isNotEmpty) {
      final name = (restaurant['name'] ?? '').toLowerCase();
      final cats = (restaurant['categories'] ?? '').toLowerCase();
      if (!name.contains(searchQuery) && !cats.contains(searchQuery)) return false;
    }
    if (selectedCategory != 'All') {
      final cats = (restaurant['categories'] ?? '').toLowerCase();
      if (!cats.contains(selectedCategory.toLowerCase())) return false;
    }
    return true;
  }

  void _openDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DrawerMenu(),
    );
  }


  void _clearSearch() {
    _searchController.clear();
    setState(() => searchQuery = '');
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontFamily: 'Sen',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text('See All',
                    style: TextStyle(fontFamily: 'Sen', fontSize: 14, color: Colors.black54)),
                Icon(Icons.chevron_right, color: Colors.black54, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('restaurants').snapshots(),
          builder: (context, snapshot) {
            List<QueryDocumentSnapshot> filteredDocs = [];
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final hasError = snapshot.hasError;

            if (snapshot.hasData) {
              filteredDocs = snapshot.data!.docs.where((doc) {
                return _filterRestaurant(doc.data() as Map<String, dynamic>);
              }).toList();
            }

            return CustomScrollView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: true,
                  expandedHeight: _expandedHeight,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _openDrawer,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.menu, color: Colors.black87, size: 20),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _scrollController,
                        builder: (context, child) {
                          double opacity = 0.0;
                          if (_scrollController.hasClients) {
                            opacity = (_scrollController.offset / _expandedHeight).clamp(0.0, 1.0);
                          }
                          return Opacity(opacity: opacity, child: child);
                        },
                        child: Text(
                          'Quickfood',
                          style: TextStyle(
                            fontFamily: 'Sen',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // 5. REPLACED OLD STACK WITH NEW WIDGET
                      const CartBadgeIcon(), 
                    ],
                  ),
                  automaticallyImplyLeading: false,
                  titleSpacing: 20,
                  flexibleSpace: FlexibleSpaceBar(
                    title: null,
                    collapseMode: CollapseMode.pin,
                    background: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 70, 20, 0),
                      child: AnimatedBuilder(
                        animation: _scrollController,
                        builder: (context, child) {
                          double opacity = 1.0;
                          if (_scrollController.hasClients) {
                            opacity = (1.0 - (_scrollController.offset / (_expandedHeight * 0.6)))
                                .clamp(0.0, 1.0);
                          }
                          return Opacity(opacity: opacity, child: child);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Welcome To Quickfood',
                              style: TextStyle(
                                fontFamily: 'Sen',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (user?.displayName != null) ...[
                              SizedBox(height: 2),
                              Text(
                                'Hi, ${user!.displayName}!',
                                style: TextStyle(
                                    fontFamily: 'Sen', fontSize: 15, color: Colors.grey),
                              ),
                            ],
                            SizedBox(height: 14),
                            HomeSearchBar(
                              controller: _searchController,
                              searchQuery: searchQuery,
                              onClear: _clearSearch,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // ... rest of your slivers remain the same
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _buildSectionHeader('All Categories', () {}),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: CategoryFilterList(
                    categories: categories,
                    selectedCategory: selectedCategory,
                    onCategorySelected: (name) =>
                        setState(() => selectedCategory = name),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: _buildSectionHeader('Open Restaurants', () {}),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16)),
                if (isLoading)
                  SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                  )
                else if (hasError)
                  SliverFillRemaining(
                    child: Center(child: Text('Error loading restaurants')),
                  )
                else if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No restaurants available',
                              style: TextStyle(
                                  fontFamily: 'Sen', fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else if (filteredDocs.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No restaurants found',
                              style: TextStyle(
                                  fontFamily: 'Sen',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          SizedBox(height: 8),
                          Text(
                            searchQuery.isNotEmpty
                                ? 'Try a different search term'
                                : 'Try selecting a different category',
                            style:
                                TextStyle(fontFamily: 'Sen', fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final doc = filteredDocs[index];
                          final restaurant = doc.data() as Map<String, dynamic>;
                          return RestaurantCard(
                            restaurantId: doc.id,
                            name: restaurant['name'] ?? 'Restaurant',
                            categories: restaurant['categories'] ?? 'Food',
                            rating: (restaurant['rating'] ?? 4.7).toDouble(),
                            deliveryTime: restaurant['deliveryTime'] ?? '20 min',
                            imageUrl: restaurant['imageUrl'] ?? '',
                            description: restaurant['description'] ?? '',
                          );
                        },
                        childCount: filteredDocs.length,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          },
        ),
      ),
    );
  }
}