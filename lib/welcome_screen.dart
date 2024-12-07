import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  final List<Map<String, String>> _screens = [
    {'title': 'ENTERTAINMENT', 'details': 'ENTERTAINMENT_DETAILS'},
    {'title': 'GASTRONOMY', 'details': 'GASTRONOMY_DETAILS'},
    {'title': 'COMMERCE', 'details': 'COMMERCE_DETAILS'},
    {'title': 'EDUCATION', 'details': 'EDUCATION_DETAILS'},
    {'title': 'WORLD_OF_TLAXCALA', 'details': 'WORLD_OF_TLAXCALA_DETAILS'},
  ];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _autoScroll();
  }

  void _autoScroll() {
    Future.delayed(const Duration(seconds: 2), () {
      if (_pageController.hasClients) {
        if (_currentPage < _screens.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      _autoScroll(); // Keep calling to loop the scroll
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo at the top center
            // const Padding(
            //   padding: EdgeInsets.only(top: 40),
            //   child: Center(
            //     child: Text(
            //       'Encuentra de \nTodo \nTlaxcala',
            //       textAlign: TextAlign.center,
            //       style: TextStyle(
            //         fontFamily: 'Courgette',
            //         fontSize: 50,
            //         fontWeight: FontWeight.bold,
            //         color: Color(0xFF0097b2),
            //       ),
            //     ),
            //   ),
            // ),
            Image.asset("logo.jpg"),

            const SizedBox(height: 40),

            // Auto-scrolling screens
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _screens.length,
                itemBuilder: (context, index) {
                  final screen = _screens[index];
                  return _buildScreen(screen['title']!, screen['details']!);
                },
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/menu');
  },
  onLongPress: () {
    Navigator.pushNamed(context, '/login');
  },
  style: ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  child: Text(context.tr('Access')),
),

            
            // // Sign-Up Button
            // OutlinedButton(
            //   onPressed: () {
            //     Navigator.pushNamed(
            //         context, '/userRegistration'); // Navigate to sign-up
            //   },
            //   style: OutlinedButton.styleFrom(
            //     minimumSize: const Size.fromHeight(50),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8.0),
            //     ),
            //   ),
            //   child: Text(context.tr('User Registration')),
            // ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen(String title, String details) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr(title),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr(details),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
