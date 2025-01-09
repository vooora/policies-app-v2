import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:policies_new/utils.dart';
import 'package:policies_new/widgets/filledbutton.dart';
import 'package:policies_new/widgets/nextquestion_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParagraphContainer extends StatefulWidget {
  const ParagraphContainer(
      {super.key, required this.headings, required this.slugs});

  final List<String> headings;
  final List<String> slugs;

  @override
  State<ParagraphContainer> createState() => _ParagraphState();
}

class _ParagraphState extends State<ParagraphContainer> {
  int index = 0;
  final FlutterTts flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String selectedLanguage = 'hi'; // Default language

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  // Load language preference from SharedPreferences
  void _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('language') ?? 'hi';
    setState(() {
      selectedLanguage = language;
    });
    _setTtsLanguage();
  }

  // Set TTS language based on preference
  Future<void> _setTtsLanguage() async {
    await flutterTts.setLanguage(getLanguageCode(selectedLanguage));
  }

  // Get TTS language code based on selected language
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
        return 'hi-IN'; // Default to English
    }
  }

  // Start TTS
  Future<void> _speak(String text) async {
    print("Selected Language: $selectedLanguage");
    print("Language Code: ${getLanguageCode(selectedLanguage)}");
    await flutterTts.setLanguage(getLanguageCode(selectedLanguage));
    await flutterTts.speak(text);
    setState(() {
      _isSpeaking = true;
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  // Stop TTS
  Future<void> _stop() async {
    await flutterTts.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final headings = widget.headings;
    final paragraphs = widget.slugs;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 47),
                    child: Column(
                      children: [
                        Text(
                          'STEP ${index + 1}',
                          style: ThemeText.titleText2,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          headings[index],
                          style: ThemeText.titleText,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          paragraphs[index],
                          style: ThemeText.bodyText,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isSpeaking
                                    ? Icons.stop
                                    : Icons.volume_up, // Use appropriate icons
                                color: ThemeColours.primaryColor, // Icon color
                                size: 50, // Adjust size as needed
                              ),
                              onPressed: () {
                                if (_isSpeaking) {
                                  _stop();
                                } else {
                                  _speak(headings[index] +
                                      ". " +
                                      paragraphs[index]);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            index == 0
                                ? const SizedBox()
                                : Expanded(
                                    child: Filledbutton(
                                    text: "Previous",
                                    buttoncolor: index == 0
                                        ? Colors.white
                                        : ThemeColours.primaryColor,
                                    onPressed: () {
                                      setState(() {
                                        if (index > 0) {
                                          index--;
                                        }
                                      });
                                    },
                                  )),
                            const SizedBox(
                              width: 10,
                            ),
                            index == headings.length - 1
                                ? const SizedBox()
                                : Expanded(
                                    child: Filledbutton(
                                    buttoncolor: index == headings.length - 1
                                        ? Colors.white
                                        : ThemeColours.accentColor,
                                    text: "Next",
                                    onPressed: () {
                                      setState(() {
                                        if (index < headings.length - 1) {
                                          index++;
                                        }
                                      });
                                    },
                                  )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const NextQuestionButton(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
