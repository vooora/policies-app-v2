import 'package:flutter/material.dart';
import 'package:policies_new/utils.dart';
import 'package:policies_new/widgets/state_form.dart';

class StateScreen extends StatelessWidget{
  const StateScreen({super.key});

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
            child: const StateForm()));

  }
}