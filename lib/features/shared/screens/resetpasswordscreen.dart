import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ForgotPasswordProvider(),
      child: Consumer<ForgotPasswordProvider>(
        builder: (context, forgotPasswordProvider, child) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Text(
                      'Forgot Password',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please sign in to your existing account',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 60),
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
                            onChanged: (value) =>
                                forgotPasswordProvider.email = value,
                            style: Theme.of(context).textTheme.bodyMedium,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'example@gmail.com',
                            ),
                          ),
                          if (forgotPasswordProvider.errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                forgotPasswordProvider.errorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontFamily: 'Sen',
                                ),
                              ),
                            ),
                          if (forgotPasswordProvider.successMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                forgotPasswordProvider.successMessage,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                  fontFamily: 'Sen',
                                ),
                              ),
                            ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: forgotPasswordProvider.isLoading
                                ? null
                                : () async {
                                    await forgotPasswordProvider.sendCode(
                                      context,
                                    );
                                  },
                            child: forgotPasswordProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'SEND RESET LINK',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
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

class ForgotPasswordProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String email = '';
  bool isLoading = false;
  String errorMessage = '';
  String successMessage = '';

  bool _validateEmail() {
    errorMessage = '';
    successMessage = '';

    if (email.trim().isEmpty) {
      errorMessage = 'Please enter your email';
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errorMessage = 'Please enter a valid email';
      notifyListeners();
      return false;
    }

    return true;
  }

  /// Sends a Firebase password reset link to the entered email address.
  Future<void> sendCode(BuildContext context) async {
    if (!_validateEmail()) {
      return;
    }

    isLoading = true;
    errorMessage = '';
    successMessage = '';
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      isLoading = false;
      successMessage = 'Reset link sent. Please check your email inbox.';
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      isLoading = false;

      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with this email';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later';
          break;
        default:
          errorMessage = 'Failed to send reset email: ${e.message}';
      }

      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (_) {
      isLoading = false;
      errorMessage = 'An error occurred. Please try again.';
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }
}
