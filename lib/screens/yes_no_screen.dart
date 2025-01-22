import 'package:flutter/material.dart';
import 'package:policies_new/utils.dart';
import 'package:policies_new/widgets/filledbutton.dart';
import 'package:policies_new/widgets/nextquestion_button.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YesNoScreen extends StatefulWidget {
  const YesNoScreen({super.key, required this.resBody});
  final Map<String, dynamic> resBody;

  @override
  State<YesNoScreen> createState() => _YesNoScreenState();
}

class _YesNoScreenState extends State<YesNoScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String selectedLanguage = 'en'; // Default language
  bool _isSpeaking = false; // Track speaking state

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  void _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('language') ?? 'en';
    setState(() {
      selectedLanguage = language;
    });
    _setTtsLanguage();
  }

  // Set the TTS language based on the selected language
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

  Future<void> _stop() async {
    if (_isSpeaking) {
      await flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String valueText = widget.resBody['value'] as String;
    String contentText = widget.resBody['content'] as String;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/assets/background2.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 47),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              valueText,
                              style: ThemeText.yesNoText,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              contentText,
                              style: ThemeText.bodyText,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const NextQuestionButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _isSpeaking ? _stop : () => _speak('$valueText. $contentText'),
        child: Icon(
          _isSpeaking ? Icons.stop : Icons.volume_up,
          color: Colors.white,
        ),
        backgroundColor: ThemeColours.primaryColor,
      ),
    );
  }
}
