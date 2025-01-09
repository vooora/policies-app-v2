import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:policies_new/data/prompts.dart';
import 'package:policies_new/models/Response.dart';
import 'package:policies_new/screens/answer_screen.dart';
import 'package:http/http.dart' as http;
import 'package:policies_new/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:policies_new/widgets/sound_recorder.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> list = <String>['English', 'Hindi', 'Telugu', 'Tamil'];
const List<String> secondList = <String>[
  'None',
  'Andaman Nicobar',
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chandigarh',
  'Chhattisgarh',
  'Delhi',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jammu and Kashmir',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Ladakh',
  'Lakshadweep',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Puducherry',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'The Dadra And Nagar Haveli And Daman And Diu',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal'
];

String getLanguageCode(String language) {
  switch (language) {
    case 'English':
      return 'en_US';
    case 'Hindi':
      return 'hi_IN';
    case 'Telugu':
      return 'te_IN';
    case 'Tamil':
      return 'ta_IN';
    default:
      return 'en_US'; // Default to English if no match found
  }
}

class InputForm extends StatefulWidget {
  const InputForm({super.key});

  @override
  State<InputForm> createState() => _InputFormState();
}

Future<String> getAudioFilePath() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String filePath = '${appDocDir.path}/my_audio.aac';
  return filePath;
}
  int getLanguageNum(String language){
    switch (language){
      case "English":
        return 0;
      case "Hindi":
        return 1;
      case "Telugu":
        return 2;
      case "Tamil":
        return 3;
      default:
        return 0;
    }
  }

class _InputFormState extends State<InputForm> {
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isPressed = false;

  String _transcription = '';
  TextEditingController _questionController = TextEditingController();

  String secondDropdownValue = secondList.first;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();

  }
String languageVal = "English";
String stateVal = "None";
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      languageVal = prefs.getString('selectedLanguage') ?? list.first;
      stateVal = prefs.getString('selectedState') ?? "None";
    });
  }
  Future<void> _listen() async {
    if (!_isListening && await _speech.initialize()) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            _transcription = val.recognizedWords;
            _questionController.text = _transcription;
          });
          print('Transcription: $_transcription');
        },
        localeId: getLanguageCode(languageVal), // Set language
      );
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<CustomResponse> fetchResponse(String question) async {
    print(question);
    var res = await http.post(
      Uri.parse('https://policies-app-backend-nlvo.onrender.com'),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName('utf-8'),
      body: {"body": _question},
    );
    final body = jsonDecode(res.body);
    if (body == "null") {
      return const CustomResponse(type: "null", body: {"null": "null"});
    }
    final resp = CustomResponse(type: body['type'], body: body['body']);
    return resp;
  }

  bool _loading = false;
  var _question = "";
  @override
  Widget build(BuildContext context) {
    final icon = _isListening ? Icons.mic : Icons.mic;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 47),
              child: Column(
                children: [
                  Text(prompts[getLanguageNum(languageVal)].title, style: ThemeText.titleText2),
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _questionController,
                          onSubmitted: (value) {
                            // Update the state with the submitted value
                            setState(() {
                              _question = value;
                            });
                          },
                          onChanged: (value) {
                            // Update the state with the typed value
                            setState(() {
                              _question = value;
                            });
                          },
                          maxLines:
                              null, // Allow the TextField to grow dynamically
                          minLines: 1, // Set the minimum number of lines
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            labelText: prompts[getLanguageNum(languageVal)].label3,
                            labelStyle: ThemeText.bodyText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTapDown: (_) async {
                          // Start listening when the button is pressed
                          await _listen();
                          setState(() {
                            _isPressed = true;
                            _question = _transcription;
                          });
                        },
                        onTapUp: (_) async {
                          // Stop listening when the button is released
                          await _speech.stop();
                          setState(() {
                            _question = _transcription;
                            _isPressed = false;
                          });
                        },
                        onTapCancel: () async {
                          // Stop listening if the press is canceled (e.g., user drags away)
                          await _speech.stop();
                          setState(() {
                            _isPressed = false;
                            _question = _transcription;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: _isPressed
                              ? 80
                              : 50, // Increase size when pressed
                          height: _isPressed
                              ? 80
                              : 50, // Increase size when pressed
                          decoration: BoxDecoration(
                            color: _isPressed
                                ? ThemeColours.accentColor
                                : ThemeColours.primaryColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(icon,
                              color: Colors.white, size: _isPressed ? 40 : 30),
                        ),
                      ),
                            color: iconCol,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.all(
                              padVal), // Optional: Add padding for better UX
                          child: Icon(icon, color: Colors.white, size: iconSize),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        //see change
                        height: 50,
                        width: 115,
                        child: GestureDetector(
                          //in attempt to make enter button on simulator work
                          onTap: () {
                            setState(() {
                              _loading = true;
                            });
                          },
                          child: IconButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                backgroundColor: MaterialStateProperty.all(
                                    ThemeColours.primaryColor)),
                            icon: !_loading
                                ? const Icon(Icons.arrow_forward_outlined,
                                    color: Colors.white)
                                : const CircularProgressIndicator(//change theme
                                    ),
                            onPressed: () async {
                              setState(() {
                                _loading = true;
                              });
                              String modifiedQuestion = _question;
                              if (stateVal != 'None') {
                                modifiedQuestion +=
                                    'I am from $stateVal. Answer in the language $languageVal';
                              }
                              final res = await fetchResponse(modifiedQuestion);
                              setState(() {
                                _loading = false;
                              });
                              if (res.type == "null") {
                                return;
                              } else {
                                if (!context.mounted) {
                                  return;
                                }
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (ctx) {
                                  return AnswerScreen(res: res);
                                }));
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
