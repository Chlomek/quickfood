import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RestaurantHomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Restaurant Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant,
                size: 100,
                color: Colors.orange,
              ),
              SizedBox(height: 24),
              Text(
                'Welcome, Restaurant Owner!',
                style: TextStyle(
                  fontFamily: 'Sen',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              if (user != null) ...[
                Text(
                  user.displayName ?? 'User',
                  style: TextStyle(
                    fontFamily: 'Sen',
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  user.email ?? '',
                  style: TextStyle(
                    fontFamily: 'Sen',
                    fontSize: 16,
                    color: Colors.white54,
                  ),
                ),
              ],
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Role: Restaurant',
                  style: TextStyle(
                    fontFamily: 'Sen',
                    fontSize: 18,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'This is the Restaurant Home Screen',
                style: TextStyle(
                  fontFamily: 'Sen',
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}