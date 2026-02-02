import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
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
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              registerProvider.register();
                            },
                            child: Text(
                              'LOG IN',
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
  String name = '';
  String email = '';
  String password = '';
  String retypePassword = '';
  bool showPassword = false;
  bool showRetypePassword = false;

  void togglePasswordVisibility() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void toggleRetypePasswordVisibility() {
    showRetypePassword = !showRetypePassword;
    notifyListeners();
  }

  void register() {
    // Implement registration logic here
    print('Name: $name, Email: $email, Password: $password, Re-type Password: $retypePassword');
  }
}