import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/feedback/feedback_methods.dart';
import 'package:tlaxcala_world/firebase_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool googleSignInLoading = false;
  void _registerUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
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
    await createUser(email, password, context);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
 Future<void> _registerWithGoogle() async {
  setState(() {
    googleSignInLoading = true;
  });

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  UserCredential userCredential;
  try {
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      userCredential = await _auth.signInWithPopup(googleProvider);
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          googleSignInLoading = false;
        });
        print('User canceled the sign-in.');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      userCredential = await _auth.signInWithCredential(credential);
    }

    final User? user = userCredential.user;
    if (user != null) {
      final String? email = user.email;
      if (email == null) {
        throw Exception("User email is null.");
      }

      bool userExists = await checkIfUserExists(email);
      if (userExists) {
        print('User is already registered.');
      } else {
        print('New user. Adding to Firestore...');
        await firestore.collection('users').doc(user.uid).set({
          'email': email,
          'createdAt': Timestamp.now(),
        });
      }
      showSnackbar(context, "Registration successful");
      Navigator.pushReplacementNamed(context, '/menu');
    }
  } catch (e, stackTrace) {
    print(e);
    debugPrint('Sign-In Failed: $e');
    debugPrint('StackTrace: $stackTrace');
   // showSnackbar(context, "Sign-In Failed: $e");
    setState(() {
      googleSignInLoading = false;
    });
  }
}

  Future<bool> checkIfUserExists(String email) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      // Query the 'users' collection where 'email' field matches the input
      final QuerySnapshot result = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // If the result has documents, the user exists
      if (result.docs.isNotEmpty) {
        print('User exists with email: $email');
        return true;
      } else {
        print('No user found with email: $email');
        return false;
      }
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
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
            const Center(
              child: Text(
                'Encuentra de \nTodo \nTlaxcala',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Courgette',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0097b2),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // Text(
            //   context.tr('User Registration'),
            //   style: Theme.of(context).textTheme.headlineLarge,
            // ),
            // const SizedBox(
            //   height: 20,
            // ),
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: context.tr('Email'),
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
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
                      keyboardType: TextInputType.text,
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
                      height: 15,
                    ),
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
                // ElevatedButton.icon(
                //   onPressed: _registerWithFacebook,
                //   style: ElevatedButton.styleFrom(
                //     minimumSize: const Size(150, 50),
                //   ),
                //   icon: const Icon(Icons.facebook),
                //   label: Text(context.tr('Facebook')),
                // ),
                ElevatedButton.icon(
                  onPressed: _registerWithGoogle,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                  ),
                  icon: const Icon(Icons.g_mobiledata),
                  label: googleSignInLoading
                      ? const CircularProgressIndicator()
                      : Text(context.tr('Google')),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                 Navigator.pushReplacementNamed(context, '/login'); // Return to login screen
              },
              child: Text(context.tr('Back To Login')),
            ),
          ],
        ),
      ),
    );
  }
}
