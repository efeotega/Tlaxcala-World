import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tlaxcala_world/feedback/feedback_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlaxcala_world/forgot_password_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberCredentials = false;
  bool isPasswordVisible = false;
  bool googleSignInLoading = false;

  final adminCredentials = {'username': 'A1311158', 'password': 'Citizen01'};
  Future<void> saveToPreferences(
      String username, String password, bool rememberMe) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    await prefs.setBool('rememberMe', rememberMe);
  }

  String _selectedLanguage = 'fr';
  void _recoverPassword() {
     Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordPage(),
                  ),
                );
  }

  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    context.setLocale(Locale(languageCode));
    setState(() {});
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    saveToPreferences(email, password, _rememberCredentials);
    if(email=="A1311158"&&password=="Citizen01"){
      Navigator.pushNamed(context,"/businessRegistration");
    }
    //get from firebase
   // await loginUser(email, password, context);
    //final user = await DatabaseHelper().getUser(username, password);
    // Navigate to Menu
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
      _emailController.text = username;
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
    _signOutUser();
  }

Future<void> _signOutUser() async {
    try {
      // Sign out from Firebase Auth
      await _auth.signOut();

      // Sign out from Google Sign-In (for Android/iOS)
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
      print('User signed out successfully.');
    } catch (e) {
      print('Error during sign-out: $e');
    }
  }
  void doRead() async {
    await readFromPreferences();
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
        // Web Authentication
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Android/iOS Authentication
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          print('User canceled the sign-in.');
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      // Check if user is logged in successfully
      final User? user = userCredential.user;
      if (user != null) {
        bool userExists = await checkIfUserExists(user.email!);
        if (userExists) {
          print('User is already registered.');
        } else {
          print('New user. You can add user to Firestore.');
          // Add the user to Firestore if needed
          await firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'createdAt': Timestamp.now(),
          });
        }
        showSnackbar(context, context.tr("Registration successfull"));
        Navigator.pushReplacementNamed(context, '/menu');
      }
    } catch (e) {
      print('Sign-In Failed: $e');
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

                // const Center(
                //   child: Text(
                //     'Encuentra de \nTodo \nTlaxcala',
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //       fontFamily: 'Courgette',
                //       fontSize: 40,
                //       fontWeight: FontWeight.bold,
                //       color: Color(0xFF0097b2),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 20),
            // const SizedBox(
            //   height: 300,
            //   child:  AssetVideoPlayer()),

                const SizedBox(
                  height: 10,
                ),
                // Text(
                //   context.tr('Login'),
                //   style: const TextStyle(fontSize: 35),
                // ),

                const SizedBox(height: 30),
                // Username Input
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
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
                  keyboardType: TextInputType.text,
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: _recoverPassword,
                      child: Text(context.tr('Recover Password')),
                    ),
                  ],
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
                const SizedBox(height: 30),
                // Text(context.tr('Or Login With')),
                // const SizedBox(height: 10),
                // ElevatedButton.icon(
                //   onPressed: _registerWithGoogle,
                //   style: ElevatedButton.styleFrom(
                //     minimumSize: const Size(150, 50),
                //   ),
                //   icon: const Icon(Icons.g_mobiledata),
                //   label: googleSignInLoading
                //       ? const CircularProgressIndicator()
                //       : Text(context.tr('Google')),
                // ),
                // const SizedBox(height: 20),
                // Registration Button
                // TextButton(
                //   onPressed: () {
                //     Navigator.pushNamed(context, '/userRegistration');
                //   },
                //   child: Text(
                //     context.tr('User Registration'),
                //     style: TextStyle(
                //       fontSize: 14,
                //       color: Theme.of(context).primaryColor,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 20),

                const Row(
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
                  ],
                ),

                const SizedBox(height: 20),
    //             GestureDetector(onTap:()async{
    //               final phoneNumber = "+246124191"; // Replace with your phone variable
    // final url = 'tel:$phoneNumber';

    // if (await canLaunchUrl(Uri.parse(url))) {
    //   await launchUrl(Uri.parse(url));
    // } else {
    //   // Handle the error, e.g., show a Snackbar
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(context.tr('Could not launch phone call'))),
    //   );
    // }
    //             },child:Text("${context.tr("Contact")} +246124191"))
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
