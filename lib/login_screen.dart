import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/language_selector_widget.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberCredentials = false;
  bool isPasswordVisible = false;

  final adminCredentials = {'username': 'A1311158', 'password': 'Citizen01'};
  Future<void> saveToPreferences(
      String username, String password, bool rememberMe) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    await prefs.setBool('rememberMe', rememberMe);
  }

  String _selectedLanguage = 'en'; // Default to English

  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    context.setLocale(Locale(languageCode));
    setState(() {});
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    saveToPreferences(username, password, _rememberCredentials);

    if (username == adminCredentials['username'] &&
        password == adminCredentials['password']) {
      // Navigate to Business Registration
      Navigator.pushNamed(context, '/businessRegistration');
    } else {
      final user = await DatabaseHelper().getUser(username, password);

      if (user != null) {
        // Navigate to Menu
        Navigator.pushNamed(context, '/menu');
      } else {
        // Show error or redirect to User Registration
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid credentials. Please register.')),
        );
      }
    }
  }

  Future<void> readFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password'); // Read a string
    bool? rememberMe = prefs.getBool('rememberMe'); // Read a boolean

    if (username != null &&
        password != null &&
        rememberMe != null &&
        rememberMe) {
      _usernameController.text = username;
      _passwordController.text = password;
    } else {
      print('No data found or rememberMe is false.');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    doRead();
    super.initState();
  }

  void doRead() async {
    await readFromPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
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
                  context.tr('Login'),
                  style: const TextStyle(fontSize: 35),
                ),

                const SizedBox(height: 30),
                // Username Input
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: context.tr('Username'),
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    prefixIcon: Icon(Icons.person,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                // Password Input
                TextField(
                  controller: _passwordController,
                  obscureText: !isPasswordVisible, // Toggle password visibility
                  decoration: InputDecoration(
                    labelText: context.tr('Password'),
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    prefixIcon:
                        Icon(Icons.lock, color: Theme.of(context).primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Radio<String>(
                      value: 'en',
                      groupValue: _selectedLanguage,
                      onChanged: (value) => _changeLanguage(value!),
                    ),
                    Text(context.tr('English')),
                    const Spacer(),
                    Radio<String>(
                      value: 'es',
                      groupValue: _selectedLanguage,
                      onChanged: (value) => _changeLanguage(value!),
                    ),
                    Text(context.tr('Español')),
                  ],
                ),

                const SizedBox(height: 16),
                // Remember Me Checkbox
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _rememberCredentials,
                      onChanged: (value) {
                        setState(() {
                          _rememberCredentials = value!;
                        });
                      },
                    ),
                    Text(
                      context.tr('Remember username and password'),
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Login Button
                ElevatedButton(
                  onPressed: _login,
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
                    context.tr('Access'),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                // Registration Button
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/userRegistration');
                  },
                  child: Text(
                    context.tr('User Registration'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
