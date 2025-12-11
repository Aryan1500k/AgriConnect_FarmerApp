import 'package:flutter/material.dart';
import 'registration_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriConnect',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green, // Fallback for older versions
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green.shade700,
          secondary: Colors.amber.shade700,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),

      ),
      home: RegistrationScreen(),
    );
  }
}