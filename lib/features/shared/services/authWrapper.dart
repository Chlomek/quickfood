import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/loginscreen.dart';
import '../../customer/screens/customerhomescreen.dart';
import '../../restaurant/screens/restauranthomescreen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String?> _resolveRestaurantId(
      FirebaseFirestore firestore, String uid, Map<String, dynamic>? userData) async {
    final directId = userData?['restaurantId'];
    if (directId is String && directId.isNotEmpty) return directId;

    final restaurantIds = userData?['restaurantIds'];
    if (restaurantIds is List && restaurantIds.isNotEmpty) {
      final first = restaurantIds.first;
      if (first is String && first.isNotEmpty) return first;
    }

    final ownedRestaurant = await firestore
        .collection('restaurants')
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .get();

    if (ownedRestaurant.docs.isNotEmpty) {
      return ownedRestaurant.docs.first.id;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 1. Check if Firebase is still determining the Auth state
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. If user is logged in, check their role in Firestore
        if (authSnapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(authSnapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              // Extract role (Assuming you have a 'role' field in your user doc)
              final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
              final String role = userData?['role'] ?? 'customer';

              
              if (role == 'restaurant') {
                return FutureBuilder<String?>(
                  future: _resolveRestaurantId(
                    FirebaseFirestore.instance,
                    authSnapshot.data!.uid,
                    userData,
                  ),
                  builder: (context, restaurantSnapshot) {
                    if (restaurantSnapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final restaurantId = restaurantSnapshot.data;
                    if (restaurantId == null) {
                      return const LoginScreen();
                    }

                    return RestaurantHomeScreen(restaurantId: restaurantId);
                  },
                );
              } else {
                return CustomerHomeScreen();
              }
            },
          );
        }

        // 3. If no user is logged in, show Login
        return const LoginScreen();
      },
    );
  }
}