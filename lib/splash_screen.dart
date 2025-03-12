import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/data_manager.dart';
import 'package:tlaxcala_world/video_screen.dart';
import 'package:tlaxcala_world/welcome_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> loadData() async {
    final businessDataManager = BusinessDataManager();

    // Simulate loading data from Hive
    final data = await businessDataManager.loadBusinessDataFromHive();
    final businessTypes = data['businessTypes'] as List<String>;
    final categoriesByType =
        data['categoriesByType'] as Map<String, List<String>>;

    for (final businessType in businessTypes) {
      final categories = categoriesByType[businessType] ?? [];
      for (final category in categories) {
        await businessDataManager.loadFilteredBusinessesFromHive(
            businessType, category);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<void>(
        future: loadData(), // Load the data while displaying the splash screen
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const SizedBox(height: 20),
                  // kIsWeb
                  //     ? Image.asset("assets/logo.jpg")
                  //     : const SizedBox(
                  //         height: 300,
                  //         child: AssetVideoPlayer(),
                  //       ),
                  SizedBox(
                          height: 300,
                          child: AssetVideoPlayer(),
                        ),
                  SizedBox(height: 20),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            Future.delayed(const Duration(seconds: 5), () {
              // Navigator.pushReplacementNamed(context, '/welcome');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const WelcomeScreen(),
                ),
              );
            });
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  kIsWeb
                      ? Image.asset("assets/logo.jpg")
                      : const SizedBox(
                          height: 300,
                          child: AssetVideoPlayer(),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
