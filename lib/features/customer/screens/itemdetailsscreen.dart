import 'package:flutter/material.dart';
import 'package:quickfood/features/customer/widgets/cart_icon.dart';
import 'package:quickfood/features/shared/services/cartProvider.dart';
import 'package:provider/provider.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String itemId;
  final String itemName;
  final String restaurantId;
  final String restaurantName;
  final String imageUrl;
  final String description;
  final int price;
  final double rating;
  final String deliveryTime;

  const ItemDetailsScreen({
    required this.itemId,
    required this.itemName,
    required this.restaurantId,
    required this.restaurantName,
    this.imageUrl = '',
    this.description = '',
    required this.price,
    this.rating = 4.7,
    this.deliveryTime = '20 min',
  });

  @override
  _ItemDetailsScreenState createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int quantity = 1;

  void _incrementQuantity() {
    setState(() {
      if (quantity < 99) {
        quantity++;
      }
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

 void _addToCart() async {
    // 1. Access the CartProvider
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // 2. Create the CartItem using your new model's required fields
    final item = CartItem(
      id: widget.itemId, 
      menuItemId: widget.itemId, // Your new model requires both
      name: widget.itemName,
      price: widget.price,
      imageUrl: widget.imageUrl,
      quantity: quantity,
    );

    // 3. Call the updated addItem method
    final success = await cartProvider.addItem(
      item: item,
      // Note: Since ItemDetailsScreen doesn't have a restaurantId passed to it yet, 
      // we'll use the name as a placeholder ID. 
      restaurantId: widget.restaurantId, 
      restaurantName: widget.restaurantName,
      onConflict: (currentRestaurantName) async {
        // 4. This automatically handles the "Different Restaurant" dialog!
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Start new basket?"),
            content: Text(
              "You already have items from $currentRestaurantName. Clear cart and start a new order from ${widget.restaurantName}?"
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false), // User cancelled
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true), // User confirmed
                child: const Text("Clear Cart", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ?? false;
      },
    );

    // Safety check: Ensure the widget is still on screen
    if (!mounted) return;

    // 5. If successful (or if they cleared the old cart and proceeded), show success!
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.itemName} (x$quantity) added to cart!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Navigate back to the menu
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = widget.price * quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Image
            Stack(
              children: [
                // Item Image
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFB0BEC5),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    image: widget.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(widget.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.imageUrl.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 80,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        )
                      : null,
                ),

                // Back Button and Cart
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.black87),
                        ),
                      ),

                      // Cart Icon
                      const CartBadgeIcon()
                    ],
                  ),
                ),
              ],
            ),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Name
                    Text(
                      widget.itemName,
                      style: TextStyle(
                        fontFamily: 'Sen',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 12),

                    // Restaurant Name
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant,
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          widget.restaurantName,
                          style: TextStyle(
                            fontFamily: 'Sen',
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Rating and Delivery Time
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 24),
                        SizedBox(width: 6),
                        Text(
                          widget.rating.toString(),
                          style: TextStyle(
                            fontFamily: 'Sen',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 20),
                        Icon(Icons.access_time, color: Colors.orange, size: 24),
                        SizedBox(width: 6),
                        Text(
                          widget.deliveryTime,
                          style: TextStyle(
                            fontFamily: 'Sen',
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Description
                    Text(
                      widget.description.isNotEmpty
                          ? widget.description
                          : 'Maecenas sed diam eget risus varius blandit sit amet non magna. Integer posuere erat a ante venenatis dapibus posuere velit aliquet.',
                      style: TextStyle(
                        fontFamily: 'Sen',
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 32),

                    // Price, Quantity, and Add to Cart Section
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Price and Quantity Selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Price
                              Text(
                                '$totalPrice Kč',
                                style: TextStyle(
                                  fontFamily: 'Sen',
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),

                              // Quantity Selector
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF1A1B2E),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  children: [
                                    // Decrement Button
                                    IconButton(
                                      onPressed: _decrementQuantity,
                                      icon: Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets.all(8),
                                      constraints: BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 36,
                                      ),
                                    ),

                                    // Quantity Display
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        quantity.toString(),
                                        style: TextStyle(
                                          fontFamily: 'Sen',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                    // Increment Button
                                    IconButton(
                                      onPressed: _incrementQuantity,
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets.all(8),
                                      constraints: BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 36,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          // Add to Cart Button
                          ElevatedButton(
                            onPressed: _addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              minimumSize: Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'ADD TO CART',
                              style: TextStyle(
                                fontFamily: 'Sen',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}