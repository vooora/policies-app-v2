import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:policies_new/utils.dart';
import 'package:policies_new/widgets/custom_modal.dart';
import 'package:policies_new/widgets/filledbutton.dart';
import 'package:policies_new/widgets/nextquestion_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionContainer extends StatefulWidget {
  const QuestionContainer({super.key, required this.flowchart});

  final List<dynamic> flowchart;

  @override
  State<QuestionContainer> createState() => _QuestionState();
}

class _QuestionState extends State<QuestionContainer> {
  int index = 0;
  String? currentActionText;
  final FlutterTts flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  // Load language preference from SharedPreferences
  void _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('language') ?? 'en';
    setState(() {
      selectedLanguage = language;
    });
    _setTtsLanguage();
  }

  // Set the TTS language
  Future<void> _setTtsLanguage() async {
    await flutterTts.setLanguage(getLanguageCode(selectedLanguage));
  }

  String getLanguageCode(String language) {
    switch (language) {
      case 'English':
        return 'en-US';
      case 'Hindi':
        return 'hi-IN';
      case 'Telugu':
        return 'te-IN';
      case 'Tamil':
        return 'ta-IN';
      default:
        return 'en-US'; // Default to English
    }
  }

  // Speak the provided text
  Future<void> _speak(String text) async {
    if (!_isSpeaking) {
      setState(() {
        _isSpeaking = true;
      });
      await flutterTts.speak(text);
      flutterTts.setCompletionHandler(() {
        setState(() {
          _isSpeaking = false;
        });
      });
    }
  }

  // Stop TTS
  Future<void> _stop() async {
    if (_isSpeaking) {
      await flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  void handleAction(dynamic action) {
    if (action is int) {
      setState(() {
        index = action;
        currentActionText = null;
      });
    } else if (action is String) {
      if (action.toLowerCase().contains("proceed to the next question")) {
        setState(() {
          index++;
          currentActionText = null;
        });
      } else {
        setState(() {
          currentActionText = action;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flowchart = widget.flowchart;
    if (flowchart.isEmpty) {
      return const Center(child: Text("No questions available."));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Card(
                color: Colors.white,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Column(
                    children: [
                      // Header Row
                      currentActionText == null && index == 0
                          ? Text(
                              "QUESTION ${index + 1}",
                              style: ThemeText.titleText2,
                            )
                          : currentActionText == null && index != 0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                        padding: const EdgeInsets.all(0),
                                        onPressed: () {
                                          setState(() {
                                            index--;
                                          });
                                        },
                                        icon: const Icon(
                                            size: 20,
                                            Icons.arrow_back_ios,
                                            color:
                                                ThemeColours.secondaryColor)),
                                    Text(
                                      "QUESTION ${index + 1}",
                                      style: ThemeText.titleText2,
                                    ),
                                    const SizedBox(width: 40),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                        padding: const EdgeInsets.all(0),
                                        onPressed: () {
                                          setState(() {
                                            currentActionText = null;
                                          });
                                        },
                                        icon: const Icon(Icons.arrow_back_ios,
                                            color:
                                                ThemeColours.secondaryColor)),
                                  ],
                                ),
                      const SizedBox(height: 20),
                      // Question or Action Text
                      Text(
                        currentActionText ??
                            flowchart[index]["question"] ??
                            "No question available.",
                        style: ThemeText.flowchartText,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Buttons
                      currentActionText == null
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Expanded(
                                    child: Filledbutton(
                                      onPressed: () {
                                        final noAction =
                                            flowchart[index]["no_action"];
                                        handleAction(noAction);
                                      },
                                      text: 'No',
                                      buttoncolor: ThemeColours.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Filledbutton(
                                      onPressed: () {
                                        final yesAction =
                                            flowchart[index]["yes_action"];
                                        handleAction(yesAction);
                                      },
                                      text: 'Yes',
                                      buttoncolor: ThemeColours.accentColor,
                                    ),
                                  ),
                                ])
                          : index < flowchart.length - 1
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                      Expanded(
                                        child: Filledbutton(
                                          onPressed: () {
                                            setState(() {
                                              index++;
                                              currentActionText = null;
                                            });
                                          },
                                          text: 'See Next Question',
                                          buttoncolor: ThemeColours.accentColor,
                                        ),
                                      ),
                                    ])
                              : const SizedBox(height: 10),
                      const SizedBox(height: 30),
                      // Read Out Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isSpeaking
                                  ? Icons.stop
                                  : Icons.volume_up, // Dynamically switch icons
                              color: ThemeColours.primaryColor, // Icon color
                              size: 30, // Icon size
                            ),
                            onPressed: () {
                              if (_isSpeaking) {
                                _stop();
                              } else {
                                // Read current question or action text
                                _speak(currentActionText ??
                                    flowchart[index]["question"] ??
                                    "No question available.");
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const NextQuestionButton(),
            ],
          ),
        )
      ],
    );
  }
}
