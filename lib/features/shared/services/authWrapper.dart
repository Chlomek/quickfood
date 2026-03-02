import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/loginscreen.dart';
import '../../customer/screens/customerhomescreen.dart';
import '../../restaurant/screens/restauranthomescreen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

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
                return RestaurantHomeScreen();
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