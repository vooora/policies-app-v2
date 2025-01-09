import 'package:flutter/material.dart';
import 'package:policies_new/widgets/input_form5.dart';

class QuestionScreen extends StatelessWidget{
  const QuestionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/background1.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: const InputForm()));

  }}