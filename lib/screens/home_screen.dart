

import 'package:flutter/material.dart';
import 'package:policies_new/widgets/input_form3.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

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
