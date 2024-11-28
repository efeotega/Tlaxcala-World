import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;

  void _registerUser() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('All fields are required.'))),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Passwords do not match.'))),
      );
      return;
    }

    try {
      await DatabaseHelper().registerUser(username, password);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Registration Successful.'))),
      );
      Navigator.pop(context); // Return to login screen
    } catch (e) {
      print('Registration Failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Registration Failed: $e'))),
      );
    }
  }

  void _recoverPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Recover password functionality not implemented.')),
    );
  }

  void _registerWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google registration not implemented.')),
    );
  }

  void _registerWithFacebook() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook registration not implemented.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Image.asset("assets/logo.png"),
            const SizedBox(
              height: 20,
            ),
            Text(
              context.tr('User Registration'),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(
              height: 20,
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: context.tr('Username'),
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock,
                            color: Theme.of(context).primaryColor),
                        labelText: context.tr('Password'),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          color: Theme.of(context).primaryColor,
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person,
                            color: Theme.of(context).primaryColor),
                        labelText: context.tr('Confirm Password'),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            color: Theme.of(context).primaryColor,
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: _recoverPassword,
                          child: Text(context.tr('Recover Password')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          backgroundColor:
                              Theme.of(context).primaryColor, // Button color
                          elevation: 5,
                        ),
                        child: Text(
                          context.tr('Register'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(context.tr('Or Register With')),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _registerWithFacebook,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                  ),
                  icon: const Icon(Icons.facebook),
                  label: Text(context.tr('Facebook')),
                ),
                ElevatedButton.icon(
                  onPressed: _registerWithGoogle,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                  ),
                  icon: const Icon(Icons.g_mobiledata),
                  label: Text(context.tr('Google')),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Return to login screen
              },
              child: Text(context.tr('Back To Login')),
            ),
          ],
        ),
      ),
    );
  }
}
