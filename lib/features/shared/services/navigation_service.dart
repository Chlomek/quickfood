import 'package:flutter/material.dart';
import '../screens/resetpasswordscreen.dart';

class NavigationService {
  /// Navigate to Forgot Password screen
  static void goToForgotPasswordScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotPasswordScreen(),
      ),
    );
  }
}
