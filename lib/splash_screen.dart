import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tlaxcala_world/video_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to the Home Page after 3 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });

    return  Scaffold(
      backgroundColor: Colors.white, // Adjust the background color if needed
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            SizedBox(height: 20),
            // App Name
            // Text(
            //   'Encuentra de \nTodo \nTlaxcala',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontFamily: 'Courgette',
            //     fontSize: 50,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.white,
            //   ),
            // ),
             const SizedBox(
              height: 300,
              child:  AssetVideoPlayer()),
          ],
        ),
      ),
    );
  }
}


void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}
