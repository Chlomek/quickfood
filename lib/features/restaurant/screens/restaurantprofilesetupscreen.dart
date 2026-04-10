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

  final List<String> _primaryTypes = [
    'Burger',
    'Pizza',
    'Sushi',
    'Italian',
    'Asian',
    'Healthy',
    'Dessert',
    'Cafe',
  ];

  static const int _maxTotalCategories = 4;

  String _selectedPrimaryType = 'Burger';
  final List<String> _customTags = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _resolvedRestaurantId;

  List<String> get _allCategories => [_selectedPrimaryType, ..._customTags];

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

        final rawPrimaryType = (data['primaryType'] ?? '').toString().trim();
        final categoriesListRaw = data['categoriesList'];
        final categoriesStringRaw = (data['categories'] ?? '').toString();

        final parsedCategories = <String>[];

        if (categoriesListRaw is List) {
          for (final item in categoriesListRaw) {
            final value = item.toString().trim();
            if (value.isNotEmpty) {
              parsedCategories.add(value);
            }
          }
        } else if (categoriesStringRaw.trim().isNotEmpty) {
          final parts = categoriesStringRaw
              .split(RegExp(r'\s*-\s*|\s*,\s*'))
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty);
          parsedCategories.addAll(parts);
        }

        final uniqueCategories = <String>[];
        for (final category in parsedCategories) {
          final exists = uniqueCategories.any(
            (c) => c.toLowerCase() == category.toLowerCase(),
          );
          if (!exists) {
            uniqueCategories.add(category);
          }
        }

        if (rawPrimaryType.isNotEmpty) {
          _selectedPrimaryType = _findExistingOrAppendPrimaryType(
            rawPrimaryType,
          );
        } else if (uniqueCategories.isNotEmpty) {
          _selectedPrimaryType = _findExistingOrAppendPrimaryType(
            uniqueCategories.first,
          );
        }

        final remaining = uniqueCategories
            .where((c) => c.toLowerCase() != _selectedPrimaryType.toLowerCase())
            .take(_maxTotalCategories - 1)
            .toList();

        _customTags
          ..clear()
          ..addAll(remaining);
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

  String _findExistingOrAppendPrimaryType(String value) {
    final existingIndex = _primaryTypes.indexWhere(
      (type) => type.toLowerCase() == value.toLowerCase(),
    );

    if (existingIndex >= 0) {
      return _primaryTypes[existingIndex];
    }

    _primaryTypes.add(value);
    return value;
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

    if (_allCategories.length > _maxTotalCategories) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can have max 4 categories in total.'),
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
        'primaryType': _selectedPrimaryType,
        'customTags': _customTags,
        'categoriesList': _allCategories,
        'categories': _allCategories.join(' - '),
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
    if (_allCategories.length >= _maxTotalCategories) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 4 categories allowed.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add category tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Tag name'),
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

    final existsInPrimary =
        _selectedPrimaryType.toLowerCase() == value.toLowerCase();
    final existsInTags = _customTags.any(
      (c) => c.toLowerCase() == value.toLowerCase(),
    );

    if (existsInPrimary || existsInTags) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This category already exists.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _customTags.add(value);
    });
  }

  void _removeCustomTag(String tag) {
    setState(() {
      _customTags.removeWhere((c) => c.toLowerCase() == tag.toLowerCase());
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
                    _buildLabel('PRIMARY TYPE'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 46,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _primaryTypes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final category = _primaryTypes[index];
                          final selected = category == _selectedPrimaryType;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedPrimaryType = category),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel(
                          'CUSTOM TAGS (${_allCategories.length}/$_maxTotalCategories)',
                        ),
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
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8A1E),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            _selectedPrimaryType,
                            style: const TextStyle(
                              fontFamily: 'Sen',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ..._customTags.map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFD8DAE1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tag,
                                  style: const TextStyle(
                                    fontFamily: 'Sen',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Color(0xFF2E3243),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _removeCustomTag(tag),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
