import 'package:ecommerce_app_new/providers/cart_provider.dart';
import 'package:ecommerce_app_new/screens/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kRichBlack = Color(0xFF1D1F24);
const Color kDarkerRed = Color(0xFF7B0000);
const Color kRed = Color(0xFFD32F2F);
const Color kLightRed = Color(0xFFFFCDD2);
const Color kOffWhite = Color(0xFFFFEBEE);

Future<void> main() async {
  // Ensure Flutter is ready and preserve the splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set persistence for web
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  // Create the CartProvider
  final cartProvider = CartProvider();
  cartProvider.initializeAuthListener();

  runApp(
    // Provide the cart provider to the entire app
    ChangeNotifierProvider.value(
      value: cartProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eCommerce App',
      theme: _buildTheme(context),
      home: const AuthWrapper(), // AuthWrapper will remove the splash screen
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: kDarkerRed,
        brightness: Brightness.dark,
        primary: kDarkerRed,
        onPrimary: Colors.white,
        secondary: kRed,
        surface: kDarkerRed,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: kDarkerRed,
      textTheme: GoogleFonts.latoTextTheme(
        Theme.of(context).textTheme,
      ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kRed),
        ),
        labelStyle: const TextStyle(color: Color.fromRGBO(211, 47, 47, 0.8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kRed, width: 2.0),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: kRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
