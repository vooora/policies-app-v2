import 'package:flutter/material.dart';
import 'package:policies_new/screens/home_screen.dart';
import 'package:policies_new/screens/web_home_screen.dart';
import 'package:policies_new/utils.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Policies App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ThemeColours.primaryColor),
        useMaterial3: true,
      ),
      home: SafeArea(child: _getHomeScreen()),
    );
  }

  static Widget _getHomeScreen() {
    if (kIsWeb) {
      // Load web-specific home screen
      return WebHomeScreen();
    } else {
      // Load mobile home screen
      return Homescreen();
    }
  }
}
