import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'restauranthomescreen.dart';

class RestaurantProfileSetupScreen extends StatefulWidget {
  final String userId;
  final String? restaurantId;
  final bool navigateToHomeOnSave;

  const RestaurantProfileSetupScreen({
    super.key,
    required this.userId,
    this.restaurantId,
    this.navigateToHomeOnSave = true,
  });

  @override
  State<RestaurantProfileSetupScreen> createState() =>
      _RestaurantProfileSetupScreenState();
}

class _RestaurantProfileSetupScreenState
    extends State<RestaurantProfileSetupScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _deliveryTimeController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final List<String> _categories = ['Burger', 'Sandwich', 'Pizza'];
  String _selectedCategory = 'Burger';

  bool _isLoading = true;
  bool _isSaving = false;
  String? _resolvedRestaurantId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _deliveryTimeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      DocumentSnapshot<Map<String, dynamic>>? restaurantDoc;

      if (widget.restaurantId != null && widget.restaurantId!.isNotEmpty) {
        final doc = await _firestore
            .collection('restaurants')
            .doc(widget.restaurantId)
            .get();
        if (doc.exists) {
          restaurantDoc = doc;
        }
      }

      restaurantDoc ??= await _findOwnedRestaurant();

      if (restaurantDoc != null) {
        final data = restaurantDoc.data() ?? <String, dynamic>{};
        _resolvedRestaurantId = restaurantDoc.id;

        _nameController.text = (data['name'] ?? '').toString();
        _descriptionController.text = (data['description'] ?? '').toString();
        _deliveryTimeController.text = (data['deliveryTime'] ?? '20 min')
            .toString();
        _imageUrlController.text = (data['imageUrl'] ?? '').toString();

        final categoryValue = (data['categories'] ?? '').toString().trim();
        if (categoryValue.isNotEmpty) {
          final exists = _categories.any(
            (c) => c.toLowerCase() == categoryValue.toLowerCase(),
          );
          if (!exists) {
            _categories.add(categoryValue);
          }
          _selectedCategory = _categories.firstWhere(
            (c) => c.toLowerCase() == categoryValue.toLowerCase(),
          );
        }
      } else {
        _deliveryTimeController.text = '20 min';
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load restaurant profile.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _findOwnedRestaurant() async {
    final ownedRestaurant = await _firestore
        .collection('restaurants')
        .where('ownerId', isEqualTo: widget.userId)
        .limit(1)
        .get();

    if (ownedRestaurant.docs.isEmpty) return null;
    return ownedRestaurant.docs.first;
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant name is required.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final payload = <String, dynamic>{
        'name': name,
        'description': _descriptionController.text.trim(),
        'categories': _selectedCategory,
        'deliveryTime': _deliveryTimeController.text.trim().isEmpty
            ? '20 min'
            : _deliveryTimeController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'ownerId': widget.userId,
        'isOpen': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      String restaurantId;
      if (_resolvedRestaurantId == null) {
        payload['rating'] = 4.7;
        payload['createdAt'] = FieldValue.serverTimestamp();

        final doc = await _firestore.collection('restaurants').add(payload);
        restaurantId = doc.id;
        _resolvedRestaurantId = restaurantId;
      } else {
        restaurantId = _resolvedRestaurantId!;
        await _firestore
            .collection('restaurants')
            .doc(restaurantId)
            .set(payload, SetOptions(merge: true));
      }

      await _firestore.collection('users').doc(widget.userId).set({
        'restaurantId': restaurantId,
        'restaurantIds': FieldValue.arrayUnion([restaurantId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.navigateToHomeOnSave
                ? 'Restaurant profile created successfully.'
                : 'Restaurant profile updated successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.navigateToHomeOnSave) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantHomeScreen(restaurantId: restaurantId),
          ),
        );
      } else {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save restaurant profile.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (value == null || value.isEmpty) return;

    final exists = _categories.any(
      (c) => c.toLowerCase() == value.toLowerCase(),
    );
    setState(() {
      if (!exists) {
        _categories.add(value);
      }
      _selectedCategory = _categories.firstWhere(
        (c) => c.toLowerCase() == value.toLowerCase(),
        orElse: () => value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _resolvedRestaurantId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Update Restaurant' : 'Set Up Restaurant',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: 'Sen',
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    _buildLabel('RESTAURANT NAME *'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'QuickFood Bistro',
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('DESCRIPTION'),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: 'Tell customers about your restaurant',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('CATEGORIES'),
                        GestureDetector(
                          onTap: _addCategory,
                          child: const Text(
                            'Add new',
                            style: TextStyle(
                              fontFamily: 'Sen',
                              color: Color(0xFFFF6B35),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 46,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final selected = category == _selectedCategory;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = category),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFFF8A1E)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFFFF8A1E)
                                      : const Color(0xFFD8DAE1),
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontFamily: 'Sen',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF2E3243),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('PREPARATION TIME'),
                    _buildTextField(
                      controller: _deliveryTimeController,
                      hint: '20 min',
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('IMAGE URL'),
                    _buildTextField(
                      controller: _imageUrlController,
                      hint: 'https://example.com/restaurant.jpg',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isEditing ? 'UPDATE PROFILE' : 'CREATE PROFILE',
                                style: const TextStyle(
                                  fontFamily: 'Sen',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1,
        fontWeight: FontWeight.w700,
        color: Color(0xFF7A7A7A),
        fontFamily: 'Sen',
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Sen'),
      decoration: InputDecoration(hintText: hint),
    );
  }
}
