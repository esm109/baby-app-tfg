import 'package:flutter/material.dart';
import 'screens/categories_screen.dart';
import 'screens/stages_screen.dart';
import 'screens/profile_setup_screen.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby App',
      debugShowCheckedModeBanner: false,
      //home: const CategoriesScreen(),
      //home: const StagesScreen(),
      home: const ProfileSetupScreen(),      
    );
  }
}