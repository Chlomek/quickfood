import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'registerscreen.dart';

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
                                onTap: () {
                                  // Handle forgot password
                                },
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
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              loginProvider.login();
                            },
                            child: Text(
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
                                  // Google icon
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
  String email = '';
  String password = '';
  bool rememberMe = false;
  bool showPassword = false;

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void login() {
    // Implement login logic here
    print('Email: $email, Password: $password, Remember Me: $rememberMe');
  }
}