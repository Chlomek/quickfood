import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegisterProvider(),
      child: Consumer<RegisterProvider>(
        builder: (context, registerProvider, child) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Sign Up',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please sign up to get started',
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
                            'NAME',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(height: 8),
                          TextField(
                            onChanged: (value) => registerProvider.name = value,
                            style: Theme.of(context).textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Peta Slovak',
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'EMAIL',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(height: 8),
                          TextField(
                            onChanged: (value) => registerProvider.email = value,
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
                            obscureText: !registerProvider.showPassword,
                            onChanged: (value) => registerProvider.password = value,
                            style: Theme.of(context).textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: '• • • • • • • • • •',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  registerProvider.showPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () => registerProvider.togglePasswordVisibility(),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'RE-TYPE PASSWORD',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(height: 8),
                          TextField(
                            obscureText: !registerProvider.showRetypePassword,
                            onChanged: (value) => registerProvider.retypePassword = value,
                            style: Theme.of(context).textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: '• • • • • • • • • •',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  registerProvider.showRetypePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () => registerProvider.toggleRetypePasswordVisibility(),
                              ),
                            ),
                          ),
                          
                          // Show error message if exists
                          if (registerProvider.errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                registerProvider.errorMessage,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontFamily: 'Sen',
                                ),
                              ),
                            ),
                          
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: registerProvider.isLoading
                                ? null
                                : () async {
                                    await registerProvider.register(context);
                                  },
                            child: registerProvider.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'SIGN UP',
                                    style: Theme.of(context).textTheme.labelLarge,
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

class RegisterProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = '';
  String email = '';
  String password = '';
  String retypePassword = '';
  bool showPassword = false;
  bool showRetypePassword = false;
  bool isLoading = false;
  String errorMessage = '';

  void togglePasswordVisibility() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void toggleRetypePasswordVisibility() {
    showRetypePassword = !showRetypePassword;
    notifyListeners();
  }

  // Validate inputs
  bool _validateInputs() {
    errorMessage = '';
    
    if (name.trim().isEmpty) {
      errorMessage = 'Please enter your name';
      notifyListeners();
      return false;
    }

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
      errorMessage = 'Please enter a password';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    if (password != retypePassword) {
      errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<void> register(BuildContext context) async {
    // Validate inputs first
    if (!_validateInputs()) {
      return;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name.trim());

      // Store additional user data in Firestore with default role 'customer'
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': 'customer', // Default role is customer
        'createdAt': FieldValue.serverTimestamp(),
        'uid': userCredential.user?.uid,
      });

      isLoading = false;
      notifyListeners();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to login screen
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      isLoading = false;
      
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
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
      
      print('Error during registration: $e');
    }
  }
}