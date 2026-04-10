import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'registerscreen.dart';
import '../services/navigation_service.dart';
import '../../customer/screens/customerhomescreen.dart';
import '../../restaurant/screens/restauranthomescreen.dart';
import '../../restaurant/screens/restaurantprofilesetupscreen.dart';

//TO DO: add Google sign in functionality and error handling for login failures

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                            onChanged: (value) =>
                                loginProvider.password = value,
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
                                onPressed: () =>
                                    loginProvider.togglePasswordVisibility(),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => loginProvider
                                  .goToForgotPasswordScreen(context),
                              child: Text(
                                'Forgot Password',
                                style: TextStyle(
                                  fontFamily: 'Sen',
                                  fontSize: 14,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
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
                              onPressed: loginProvider.isLoading
                                  ? null
                                  : () async {
                                      await loginProvider.googleLogin(context);
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
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static const String _googleServerClientId =
      '48032303630-rv82au8mk5mheu3esqqa3ui7l03po031.apps.googleusercontent.com';
  bool _googleInitialized = false;

  String email = '';
  String password = '';
  bool showPassword = false;
  bool isLoading = false;
  String errorMessage = '';

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
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

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

  // Resolve the restaurant document id for a restaurant user.
  Future<String?> _getRestaurantId(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();

      final directId = userData?['restaurantId'];
      if (directId is String && directId.isNotEmpty) return directId;

      final restaurantIds = userData?['restaurantIds'];
      if (restaurantIds is List && restaurantIds.isNotEmpty) {
        final first = restaurantIds.first;
        if (first is String && first.isNotEmpty) return first;
      }

      final ownedRestaurant = await _firestore
          .collection('restaurants')
          .where('ownerId', isEqualTo: uid)
          .limit(1)
          .get();

      if (ownedRestaurant.docs.isNotEmpty) {
        return ownedRestaurant.docs.first.id;
      }

      return null;
    } catch (e) {
      print('Error getting restaurant id: $e');
      return null;
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
        final restaurantId = await _getRestaurantId(userCredential.user!.uid);
        if (restaurantId == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantProfileSetupScreen(
                userId: userCredential.user!.uid,
              ),
            ),
          );
          return;
        }

        // Navigate to restaurant home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RestaurantHomeScreen(restaurantId: restaurantId),
          ),
        );
      } else {
        // Navigate to customer home screen (default)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerHomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        try {
          final newUserCredential = await _auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

          final user = newUserCredential.user;
          if (user == null) {
            throw Exception('Account creation failed');
          }

          final fallbackName = _nameFromEmail(email.trim());
          await user.updateDisplayName(fallbackName);

          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? fallbackName,
            'email': user.email ?? email.trim(),
            'role': 'customer',
            'createdAt': FieldValue.serverTimestamp(),
            'uid': user.uid,
          }, SetOptions(merge: true));

          isLoading = false;
          notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No account found. New account created!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CustomerHomeScreen()),
          );
          return;
        } on FirebaseAuthException catch (createError) {
          isLoading = false;

          switch (createError.code) {
            case 'weak-password':
              errorMessage = 'Password is too weak for a new account';
              break;
            case 'email-already-in-use':
              errorMessage =
                  'This email was just registered. Please try logging in again';
              break;
            default:
              errorMessage = 'Account creation failed: ${createError.message}';
          }

          notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
          return;
        } catch (createError) {
          isLoading = false;
          errorMessage = 'Could not create account. Please try again.';
          notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
          return;
        }
      }

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
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      isLoading = false;
      errorMessage = 'An error occurred. Please try again.';
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );

      print('Error during login: $e');
    }
  }

  String _nameFromEmail(String value) {
    final local = value.split('@').first.trim();
    if (local.isEmpty) return 'User';

    final cleaned = local.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').trim();
    if (cleaned.isEmpty) return 'User';

    return cleaned
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Future<void> googleLogin(BuildContext context) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      await _ensureGoogleInitialized();

      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        isLoading = false;
        errorMessage =
            'Google sign-in configuration is incomplete (missing ID token).';
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
        return;
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Google sign-in failed');
      }

      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'name': user.displayName ?? 'User',
          'email': user.email ?? '',
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
          'uid': user.uid,
        });
      } else {
        await userRef.set({
          'name': user.displayName ?? (userDoc.data()?['name'] ?? 'User'),
          'email': user.email ?? (userDoc.data()?['email'] ?? ''),
          'uid': user.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      final userRole = await _getUserRole(user.uid);

      isLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google login successful!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      if (userRole == 'restaurant') {
        final restaurantId = await _getRestaurantId(user.uid);
        if (restaurantId == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantProfileSetupScreen(userId: user.uid),
            ),
          );
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RestaurantHomeScreen(restaurantId: restaurantId),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerHomeScreen()),
        );
      }
    } on GoogleSignInException catch (e) {
      isLoading = false;

      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User dismissed account picker; treat as a normal cancellation.
        notifyListeners();
        return;
      }

      switch (e.code) {
        case GoogleSignInExceptionCode.clientConfigurationError:
          errorMessage =
              'Google Sign-In is not configured correctly for this app (${e.description ?? 'client configuration error'}).';
          break;
        case GoogleSignInExceptionCode.providerConfigurationError:
          errorMessage =
              'Google provider configuration error (${e.description ?? 'provider configuration error'}).';
          break;
        case GoogleSignInExceptionCode.interrupted:
        case GoogleSignInExceptionCode.uiUnavailable:
          errorMessage = 'Google sign-in was interrupted. Please try again.';
          break;
        default:
          errorMessage =
              'Google sign-in failed (${e.code.name}). ${e.description ?? ''}'
                  .trim();
      }
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } on FirebaseAuthException catch (e) {
      isLoading = false;

      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
              'An account already exists with a different sign-in method';
          break;
        case 'invalid-credential':
          errorMessage =
              'Google credential rejected. Check Firebase Auth Google provider, SHA-1/SHA-256 fingerprints, and app package setup.';
          break;
        case 'missing-id-token':
          errorMessage =
              'Google did not return an ID token. Verify Google Sign-In OAuth client configuration.';
          break;
        default:
          errorMessage = 'Google login failed: ${e.message}';
      }

      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      isLoading = false;
      errorMessage = 'Google login failed. Please try again.';
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );

      print('Error during Google login: $e');
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    if (_googleServerClientId.isEmpty) {
      throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
        description:
            'serverClientId must be provided on android. Set _googleServerClientId in LoginProvider.',
      );
    }

    await _googleSignIn.initialize(serverClientId: _googleServerClientId);
    _googleInitialized = true;
  }

  void goToForgotPasswordScreen(BuildContext context) {
    NavigationService.goToForgotPasswordScreen(context);
  }
}
