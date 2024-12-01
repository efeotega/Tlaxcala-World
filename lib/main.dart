import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/add_business_screen.dart';
import 'package:tlaxcala_world/delete_business_screen.dart';
import 'package:tlaxcala_world/business_registration_screen.dart';
import 'package:tlaxcala_world/splash_screen.dart';
import 'package:tlaxcala_world/welcome_screen.dart';
import 'login_screen.dart';
import 'menu_screen.dart';
import 'user_registration_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
//   final dbPath = await getDatabasesPath();
// await deleteDatabase(join(dbPath, 'app_database.db'));

// sqfliteFfiInit();
//   databaseFactory = databaseFactoryFfi;
  runApp(
    EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('en'),
          Locale('es'),
          Locale('es', 'MX')],
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
        '/welcome': (context) =>  const WelcomeScreen(),
        '/':(context)=> const SplashScreen(),
        '/userRegistration': (context) => const UserRegistrationScreen(),
        '/businessRegistration': (context) =>  const BusinessRegistrationScreen(),
      },
      theme: ThemeData.light().copyWith(
  primaryColor: const Color(0xFF0097b2),
  colorScheme: ThemeData.light().colorScheme.copyWith(primary: Colors.blue),
),
darkTheme: ThemeData.dark().copyWith(
  primaryColor: const Color(0xFF0097b2),
  colorScheme: ThemeData.dark().colorScheme.copyWith(primary: Colors.blueGrey),
),
themeMode: ThemeMode.system, // Use system theme by default

    );
  }
}
