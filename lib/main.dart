import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/add_business_screen.dart';
import 'package:tlaxcala_world/all_users.dart';
import 'package:tlaxcala_world/delete_business_screen.dart';
import 'package:tlaxcala_world/business_registration_screen.dart';
import 'package:tlaxcala_world/splash_screen.dart';
import 'package:tlaxcala_world/welcome_screen.dart';
import 'login_screen.dart';
import 'menu_screen.dart';
import 'user_registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('en'),
          Locale('es'),
          Locale('es', 'MX'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: '/',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/addBusiness': (context) => const AddBusinessScreen(),
        '/deleteBusiness': (context) => const DeleteBusinessScreen(),
        '/menu': (context) => const MenuScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/': (context) => const SplashScreen(),
        '/userRegistration': (context) => const UserRegistrationScreen(),
        '/businessRegistration': (context) => const BusinessRegistrationScreen(),
        '/view-users': (context) => UsersPage(),
      },
      theme: ThemeData.light().copyWith(
        
        primaryColor: const Color(0xFF270949),
        //primaryColor: const Color(0xFF0097b2),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'Montserrat',
              bodyColor: const Color(0xFF270949),
              displayColor: const Color(0xFF270949),
            ),
        colorScheme: ThemeData.light().colorScheme.copyWith(
              primary:const Color(0xFF270949),
              surface: const Color(0xFFFFFFFF),
            ),
      ),
      // darkTheme: ThemeData.dark().copyWith(
      //   primaryColor: const Color(0xFF0097b2),
      //   textTheme: ThemeData.dark().textTheme.apply(
      //         fontFamily: 'Montserrat',
      //         bodyColor: const Color(0xFF270949),
      //         displayColor: const Color(0xFF270949),
      //       ),
      //   colorScheme: ThemeData.dark().colorScheme.copyWith(
      //         primary: Colors.blueGrey,
      //         surface: const Color(0xFF121212),
      //       ),
      // ),
      themeMode: ThemeMode.light,
    );
  }
}
