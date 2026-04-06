import 'package:flutter/material.dart';

class RestaurantBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onHomeTap;
  final VoidCallback onCenterTap;
  final VoidCallback onMenuTap;

  const RestaurantBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onHomeTap,
    required this.onCenterTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onHomeTap,
            child: Icon(
              Icons.grid_view_rounded,
              size: 26,
              color: selectedIndex == 0
                  ? const Color(0xFFFF6B35)
                  : const Color(0xFFBDBDBD),
            ),
          ),
          GestureDetector(
            onTap: onCenterTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFFF6B35), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Color(0xFFFF6B35), size: 26),
            ),
          ),
          GestureDetector(
            onTap: onMenuTap,
            child: Icon(
              Icons.menu,
              size: 26,
              color: selectedIndex == 2
                  ? const Color(0xFFFF6B35)
                  : const Color(0xFFBDBDBD),
            ),
          ),
        ],
      ),
    );
  }
}
