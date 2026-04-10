import 'package:flutter/material.dart';

class RestaurantTopHeader extends StatelessWidget {
  final String restaurantName;
  final bool isOpen;
  final bool isLoading;
  final VoidCallback onMenuTap;
  final VoidCallback onToggleOpenTap;

  const RestaurantTopHeader({
    super.key,
    required this.restaurantName,
    required this.isOpen,
    required this.isLoading,
    required this.onMenuTap,
    required this.onToggleOpenTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      color: const Color(0xFFF4F6FA),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap,
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
                Text(
                  restaurantName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    fontFamily: 'Sen',
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggleOpenTap,
            child: Stack(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOpen
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFBDBDBD),
                    boxShadow: [
                      BoxShadow(
                        color: (isOpen ? const Color(0xFF4CAF50) : Colors.grey)
                            .withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isOpen
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
                      color: isOpen
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
}
