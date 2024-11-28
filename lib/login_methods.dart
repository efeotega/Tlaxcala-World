import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tlaxcala_world/database_helper.dart';
void _registerWithGoogle(BuildContext context) async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GoogleSignInAccount? account = await googleSignIn.signIn();

  if (account != null) {
    // Save the user in your SQLite database
    await DatabaseHelper().registerUser(account.email, 'google_auth');
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(context.tr('Google registration successful!'))),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(context.tr('Google registration canceled.'))),
    );
  }
}

void _registerWithFacebook(BuildContext context) async {
  final LoginResult result = await FacebookAuth.instance.login();

  if (result.status == LoginStatus.success) {
    final userData = await FacebookAuth.instance.getUserData();
    await DatabaseHelper().registerUser(
      userData['email'],
      'facebook_auth',
    );
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(context.tr('Facebook registration successful!'))),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(context.tr('Facebook registration failed.'))),
    );
  }
}
