import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/splash_screen.dart';

void main() {
  runApp(const PanorApp());
}

class PanorApp extends StatelessWidget {
  const PanorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PANOR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
