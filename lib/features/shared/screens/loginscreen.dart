import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registerscreen.dart';
import '../services/navigation_service.dart';
import '../../customer/screens/customerhomescreen.dart';
import '../../restaurant/screens/restauranthomescreen.dart';

//TO DO: add Google sign in functionality and error handling for login failures

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginProvider(),
      child: Consumer<LoginProvider>( 
        builder: (context, loginProvider, child) {
          return Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Log In',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please sign in to your existing account',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 40),
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EMAIL',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(height: 8),
                          TextField(
                            onChanged: (value) => loginProvider.email = value,
                            style: Theme.of(context).textTheme.bodyMedium,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'example@gmail.com',
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'PASSWORD',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(height: 8),
                          TextField(
                            obscureText: !loginProvider.showPassword,
                            onChanged: (value) => loginProvider.password = value,
                            style: Theme.of(context).textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: '• • • • • • • • • •',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  loginProvider.showPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () => loginProvider.togglePasswordVisibility(),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Checkbox(
                                      value: loginProvider.rememberMe,
                                      onChanged: (value) => loginProvider.toggleRememberMe(),
                                      activeColor: Colors.orange,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Remember me',
                                    style: TextStyle(
                                      fontFamily: 'Sen',
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => loginProvider.goToForgotPasswordScreen(context),
                                child: Text(
                                  'Forgot Password',
                                  style: TextStyle(
                                    fontFamily: 'Sen',
                                    fontSize: 14,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Show error message if exists
                          if (loginProvider.errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                loginProvider.errorMessage,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontFamily: 'Sen',
                                ),
                              ),
                            ),
                          
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: loginProvider.isLoading
                                ? null
                                : () async {
                                    await loginProvider.login(context);
                                  },
                            child: loginProvider.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'LOG IN',
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account?',
                                style: TextStyle(
                                  fontFamily: 'Sen',
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'SIGN UP',
                                  style: TextStyle(
                                    fontFamily: 'Sen',
                                    fontSize: 14,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Or',
                                style: TextStyle(
                                  fontFamily: 'Sen',
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle Google sign in
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF5F5F5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'G',
                                        style: TextStyle(
                                          fontFamily: 'Sen',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
          );
        },
      ),
    );
  }
}

class LoginProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String email = '';
  String password = '';
  bool rememberMe = false;
  bool showPassword = false;
  bool isLoading = false;
  String errorMessage = '';

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    showPassword = !showPassword;
    notifyListeners();
  }

  // Validate inputs
  bool _validateInputs() {
    errorMessage = '';

    if (email.trim().isEmpty) {
      errorMessage = 'Please enter your email';
      notifyListeners();
      return false;
    }

    // Basic email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errorMessage = 'Please enter a valid email';
      notifyListeners();
      return false;
    }

    if (password.isEmpty) {
      errorMessage = 'Please enter your password';
      notifyListeners();
      return false;
    }

    return true;
  }

  // Get user role from Firestore
  Future<String> _getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (userDoc.exists) {
        // Get role from Firestore, default to 'customer' if not set
        return userDoc.get('role') ?? 'customer';
      }
      
      // If user document doesn't exist, return default role
      return 'customer';
    } catch (e) {
      print('Error getting user role: $e');
      // Return default role if there's an error
      return 'customer';
    }
  }

  Future<void> login(BuildContext context) async {
    // Validate inputs first
    if (!_validateInputs()) {
      return;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      // Sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Get user role from Firestore
      String userRole = await _getUserRole(userCredential.user!.uid);

      isLoading = false;
      notifyListeners();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      // Navigate based on user role
      if (userRole == 'restaurant') {
        // Navigate to restaurant home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantHomeScreen(),
          ),
        );
      } else {
        // Navigate to customer home screen (default)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerHomeScreen(),
          ),
        );
      }

    } on FirebaseAuthException catch (e) {
      isLoading = false;

      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }

      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );

    } catch (e) {
      isLoading = false;
      errorMessage = 'An error occurred. Please try again.';
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );

      print('Error during login: $e');
    }
  }

  void goToForgotPasswordScreen(BuildContext context) {
    NavigationService.goToForgotPasswordScreen(context);
  }
}