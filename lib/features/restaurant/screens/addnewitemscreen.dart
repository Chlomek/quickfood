import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddNewItemScreen extends StatefulWidget {
  final String restaurantId;
  final String? menuItemId;
  final Map<String, dynamic>? initialData;

  const AddNewItemScreen({
    super.key,
    required this.restaurantId,
    this.menuItemId,
    this.initialData,
  });

  @override
  State<AddNewItemScreen> createState() => _AddNewItemScreenState();
}

class _AddNewItemScreenState extends State<AddNewItemScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  final List<String> _categories = ['Burger', 'Sandwich', 'Pizza'];
  String _selectedCategory = 'Burger';

  String _imageUrl = '';
  bool _isSaving = false;

  bool get _isEditMode => widget.menuItemId != null;

  @override
  void initState() {
    super.initState();
    _prefillFormIfNeeded();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final snapshot = await _firestore
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('menu')
        .get();

    final categorySet = <String>{..._categories};
    for (final doc in snapshot.docs) {
      final category = (doc.data()['category'] ?? '').toString().trim();
      if (category.isNotEmpty) {
        categorySet.add(category);
      }
    }

    if (!mounted) return;
    setState(() {
      _categories
        ..clear()
        ..addAll(categorySet.toList());
      if (_isEditMode && widget.initialData != null) {
        final initialCategory =
            (widget.initialData!['category'] ?? '').toString().trim();
        if (initialCategory.isNotEmpty && !_categories.contains(initialCategory)) {
          _categories.add(initialCategory);
        }
      }
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = _categories.first;
      }
    });
  }

  void _prefillFormIfNeeded() {
    final data = widget.initialData;
    if (data == null) return;

    _nameController.text = (data['name'] ?? '').toString();
    final price = data['price'];
    if (price != null) {
      _priceController.text = price.toString();
    }
    _detailsController.text = (data['description'] ?? '').toString();
    _imageUrl = (data['imageUrl'] ?? '').toString();

    final category = (data['category'] ?? '').toString().trim();
    if (category.isNotEmpty) {
      _selectedCategory = category;
    }
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _priceController.clear();
      _detailsController.clear();
      _imageUrl = '';
      _selectedCategory = _categories.isNotEmpty ? _categories.first : 'Burger';
    });
  }

  Future<void> _promptImageUrl() async {
    final controller = TextEditingController(text: _imageUrl);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'https://...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Use URL'),
          ),
        ],
      ),
    );

    if (value == null) return;
    setState(() => _imageUrl = value);
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

    final exists = _categories.any((c) => c.toLowerCase() == value.toLowerCase());
    if (!exists) {
      setState(() {
        _categories.add(value);
        _selectedCategory = value;
      });
    } else {
      setState(() {
        _selectedCategory = _categories.firstWhere(
          (c) => c.toLowerCase() == value.toLowerCase(),
        );
      });
    }
  }

  Future<void> _saveItem() async {
    final name = _nameController.text.trim();
    final rawPrice = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final price = int.tryParse(rawPrice);
    final details = _detailsController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter item name')),
      );
      return;
    }

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid price')),
      );
      return;
    }

    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose category')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final payload = {
        'name': name,
        'category': _selectedCategory,
        'price': price,
        'imageUrl': _imageUrl,
        'description': details,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final menuCollection = _firestore
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menu');

      if (_isEditMode) {
        await menuCollection.doc(widget.menuItemId!).update(payload);
      } else {
        await menuCollection.add({...payload, 'createdAt': FieldValue.serverTimestamp()});
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode
              ? 'Item updated successfully'
              : 'Item added successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE5E8EE),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF2E3243)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Center(
                      child: Text(
                        _isEditMode ? 'Edit Item' : 'Add New Items',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Sen',
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: Color(0xFF2D2F3A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _resetForm,
                    child: const Text(
                      'RESET',
                      style: TextStyle(
                        fontFamily: 'Sen',
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'ITEM NAME',
                style: TextStyle(
                  fontFamily: 'Sen',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A3E4C),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration('Mazalichiken Halim'),
              ),
              const SizedBox(height: 22),
              const Text(
                'UPLOAD PHOTO/VIDEO',
                style: TextStyle(
                  fontFamily: 'Sen',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A3E4C),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _promptImageUrl,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF97A7B8),
                    borderRadius: BorderRadius.circular(16),
                    image: _imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageUrl.isEmpty
                      ? const Icon(Icons.image_outlined, color: Colors.white70, size: 28)
                      : null,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'PRICE',
                style: TextStyle(
                  fontFamily: 'Sen',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A3E4C),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 130,
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('400 Kč'),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CATEGORY',
                    style: TextStyle(
                      fontFamily: 'Sen',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3A3E4C),
                      letterSpacing: 1,
                    ),
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
                      onTap: () => setState(() => _selectedCategory = category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFFF8A1E) : Colors.transparent,
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
                            color: selected ? Colors.white : const Color(0xFF2E3243),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'DETAILS',
                style: TextStyle(
                  fontFamily: 'Sen',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3A3E4C),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _detailsController,
                maxLines: 4,
                decoration: _inputDecoration(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    disabledBackgroundColor: const Color(0xFFFFB088),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'SAVE CHANGES',
                          style: TextStyle(
                            fontFamily: 'Sen',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Sen',
        color: Color(0xFFA0A6B3),
      ),
      filled: true,
      fillColor: const Color(0xFFF4F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD8DAE1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD8DAE1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF8A1E), width: 1.2),
      ),
    );
  }

}
