import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlaxcala_world/add_business_screen.dart';
import 'package:tlaxcala_world/all_users.dart';
import 'package:tlaxcala_world/analytics_page.dart';
import 'package:tlaxcala_world/business_model.dart';
import 'package:tlaxcala_world/delete_business_screen.dart';
import 'package:tlaxcala_world/business_registration_screen.dart';
import 'package:tlaxcala_world/show_link_details.dart';
import 'package:tlaxcala_world/splash_screen.dart';
import 'login_screen.dart';
import 'menu_screen.dart';
import 'user_registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> _resetServerState(SharedPreferences prefs) async {
  await prefs.setString('server_checked', '0');
  await prefs.setString(
      'server_checked_date', DateTime.now().toIso8601String());
  // Close all boxes and delete all boxes from disk.
  await Hive.close();
  await Hive.deleteFromDisk();
}

Future<void> deleteOldHiveBoxes() async {
  if (kIsWeb) return;

  // Get today's date in the format yyyy-MM-dd
  final String today = DateTime.now().toIso8601String().split('T').first;
  final String todayBoxName = 'business_data_$today';

  // Get the Hive directory
  final Directory appDir = await getApplicationDocumentsDirectory();
  // Hive boxes are usually stored in the root of appDir (or in appDir/hive if you set that up)
  final Directory hiveDir = Directory(appDir.path);

  if (await hiveDir.exists()) {
    // List all files in the Hive directory
    final files = hiveDir.listSync();

    for (final file in files) {
      // We assume the file name follows the pattern: business_data_yyyy-MM-dd.hive
      final String fileName = file.uri.pathSegments.last;

      // Check if the file belongs to a business_data box
      if (fileName.startsWith('business_data_') && fileName.endsWith('.hive')) {
        // Extract the box name (remove the ".hive" extension)
        final String boxName = fileName.replaceAll('.hive', '');
        // If it's not today's box, delete it.
        if (boxName != todayBoxName) {
          try {
            if (Hive.isBoxOpen(boxName)) {
              final box = Hive.box(boxName);
              await box.close();
            }
            print("Deleting old Hive box: $boxName");
            await Hive.deleteBoxFromDisk(boxName);
          } catch (e) {
            print('Failed to delete box $boxName: $e');
          }
        }
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await deleteOldHiveBoxes();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //await resetServerCheckedIfNotToday();
  await EasyLocalization.ensureInitialized();

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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   // context.setLocale(const Locale('es'));
    return MaterialApp(
      title: "Lo-e",
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');

        if (uri.path == '/showlinkdetails') {
          final params = uri.queryParameters;

          // Check if parameters exist
          if (params.isNotEmpty && params['id'] != null) {
            final business = Business(
              id: params['id'] ?? '',
              name: params['name'] ?? '',
              municipal: params['municipal'] ?? '',
              businessType: params['businessType'] ?? '',
              category: params['category'] ?? '',
              review: params['review'] ?? '',
              phone: params['phone'] ?? '',
              address: params['address'] ?? '',
              services: params['services'] ?? '',
              addedValue: params['addedValue'] ?? '',
              opinions: params['opinions'] ?? '',
              whatsapp: params['whatsapp'] ?? '',
              promotions: params['promotions'] ?? '',
              locationLink: params['locationLink'] ?? '',
              facebookPage: params['facebookPage'] ?? '',
              website: params['website'] ?? '',
              eventDate: params['eventDate'] ?? '',
              openingHours: params['openingHours'] ?? '',
              closingHours: params['closingHours'] ?? '',
              prices: params['prices'] ?? '',
              imagePaths: (params['imagePaths']?.split(',') ?? []),
            );

            return MaterialPageRoute(
              builder: (context) => ShowLinkDetailsScreen(business: business),
            );
          } else {
            print("no laid params");
            // No valid parameters, show splash screen
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
          }
        }

        // If the route is null or empty, show splash screen as the fallback
        if (settings.name == null ||
            settings.name!.isEmpty ||
            settings.name == '/') {
          if (uri.path == '/showlinkdetails') {
            final params = uri.queryParameters;

            // Check if parameters exist
            if (params.isEmpty && params['id'] == null) {
              print("no valaid params");
              return MaterialPageRoute(
                  builder: (context) => const SplashScreen());
            }
          }
        }

        // Unknown route, show splash screen
        if (uri.path == '/showlinkdetails') {
          final params = uri.queryParameters;

          // Check if parameters exist
          if (params.isEmpty && params['id'] == null) {
            print("no valaid parameter");
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
          }
        } else {
          if (!kIsWeb) {
            return MaterialPageRoute(
                builder: (context) => const SplashScreen());
          }
        }
        return null;
      },
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) {
          return const LoginScreen();
        },
        '/splashscreen': (context) => const SplashScreen(),
        '/analytics': (context) => const AnalyticsPage(),
        '/addBusiness': (context) => const AddBusinessScreen(),
        '/deleteBusiness': (context) => const DeleteBusinessScreen(),
        '/menu': (context) => const MenuScreen(),
        '/userRegistration': (context) => const UserRegistrationScreen(),
        '/businessRegistration': (context) =>
            const BusinessRegistrationScreen(),
        '/view-users': (context) => const UsersPage(),
      },
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF270949),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'Montserrat',
              bodyColor: const Color(0xFF270949),
              displayColor: const Color(0xFF270949),
            ),
        colorScheme: ThemeData.light().colorScheme.copyWith(
              primary: const Color(0xFF270949),
              surface: const Color(0xFFFFFFFF),
            ),
      ),
      themeMode: ThemeMode.light,
    );
  }
}
