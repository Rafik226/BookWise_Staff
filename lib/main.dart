import 'package:bookwise_staff/screens/auth/login_screen.dart';
import 'package:bookwise_staff/screens/splash_screen.dart';
import 'package:bookwise_staff/services/book_service.dart';
import 'package:bookwise_staff/services/member_service.dart';
import 'package:bookwise_staff/services/request_service.dart';
import 'package:bookwise_staff/services/staff_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
   // webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider:kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
   // appleProvider: AppleProvider.appAttest,
  );
  
  FirebaseAuth.instance.setLanguageCode('fr'); // Pour définir la langue en français, par exemple

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BookService>(
          create: (_) => BookService(),
        ),
        ChangeNotifierProvider<MemberService>(
          create: (_) => MemberService(),
        ),
        ChangeNotifierProvider<StaffService>(
          create: (_) => StaffService(),
        ),
        ChangeNotifierProvider<RequestService>(
          create: (_) => RequestService(),
        ),
        
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
      '/home': (context) => const LoginScreen(),
    },
      ),
    );
  }
}
