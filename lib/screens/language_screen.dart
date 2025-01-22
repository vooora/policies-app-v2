import 'package:flutter/material.dart';
import 'package:policies_new/widgets/input_form5-merge.dart';
import 'package:policies_new/widgets/language_form.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});
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
            child: const LanguageForm()));
  }
}
