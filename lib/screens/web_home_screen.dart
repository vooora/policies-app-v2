import 'package:flutter/material.dart';
import 'package:policies_new/screens/flowchart_screen.dart';
import 'package:policies_new/screens/paragraph_screen.dart';
import 'package:policies_new/screens/yes_no_screen.dart';
import 'package:policies_new/widgets/input_form.dart';

class WebHomeScreen extends StatelessWidget {
  const WebHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/background1.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: const InputForm()));
  }
}
