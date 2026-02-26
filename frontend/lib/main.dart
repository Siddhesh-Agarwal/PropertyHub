import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'pages/auth_reset_password_page.dart';
import 'pages/auth_signin_page.dart';
import 'pages/auth_signup_page.dart';
import 'pages/contract_page.dart';
import 'pages/feedback_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_edit_page.dart';
import 'pages/profile_page.dart';
import 'pages/property_add_page.dart';
import 'pages/property_edit_page.dart';
import 'pages/property_contract_edit_page.dart';
import 'pages/property_contract_page.dart';
import 'pages/property_view_page.dart';
import 'pages/service_request_page.dart';
import 'pages/service_view_page.dart';
import 'pages/sos_page.dart';
import 'pages/user_add_page.dart';
import 'pages/user_page.dart';
import 'services/auth_services.dart';
import 'services/constants.dart';
import 'ui/auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase App Check with appropriate providers
  if (kDebugMode) {
    // In debug mode, use debug provider for both platforms
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } else {
    // In release mode, use secure providers
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
  }

  await authService.value.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
          titleSmall: GoogleFonts.inter(fontSize: 18),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/home': (context) => const HomePage(),
        '/users': (context) => const AdminGuard(child: UserPage()),
        '/users/add': (context) => const AdminGuard(child: AddUserPage()),
        '/register': (context) => const AuthSignupPage(),
        '/login': (context) => const AuthSigninPage(),
        '/forgot-password': (context) => const AuthResetPasswordPage(),
        '/profile': (context) => const ProfilePage(),
        '/profile/edit': (context) => const EditProfilePage(),
        '/properties': (context) => const AdminGuard(child: PropertiesPage()),
        '/properties/add':
            (context) => const AdminGuard(child: AddPropertyPage()),
        '/properties/edit':
            (context) => const AdminGuard(child: EditPropertyPage()),
        '/properties/contract':
            (context) => const AdminGuard(child: PropertyContractPage()),
        '/properties/contract/edit':
            (context) => const AdminGuard(child: PropertyContractEditPage()),
        '/contract': (context) => const UserGuard(child: ContractPage()),
        '/feedback': (context) => const FeedbackPage(),
        '/service': (context) => const ViewServiceRequestPage(),
        '/service/request':
            (context) => const UserGuard(child: RequestServicePage()),
        '/sos': (context) => const UserGuard(child: SosPage()),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
