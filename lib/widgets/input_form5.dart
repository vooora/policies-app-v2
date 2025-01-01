import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _InputFormState extends State<InputForm> {
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  String _transcription = '';
  TextEditingController _questionController = TextEditingController();

  String secondDropdownValue = secondList.first;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dropdownValue = prefs.getString('selectedLanguage') ?? list.first;
    });
  }

  Future<void> _saveLanguagePreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
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
        localeId: getLanguageCode(dropdownValue), // Set language
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
  String dropdownValue = list.first;
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
                  Text('ASK A QUESTION', style: ThemeText.titleText2),
                  const SizedBox(height: 50),
                  DropdownButtonFormField(
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5)),
                        label: Text("Choose Input Language",
                            style: ThemeText.bodyText)),
                    value: dropdownValue,
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                      _saveLanguagePreference(value!);
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 13),
                  DropdownButtonFormField(
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5)),
                        label: Text("Choose Input State",
                            style: ThemeText.bodyText)),
                    value: secondDropdownValue,
                    onChanged: (String? value) {
                      setState(() {
                        secondDropdownValue = value!;
                      });
                    },
                    items: secondList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 10.9)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 13),
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
                            labelText: "Enter your question",
                            labelStyle: ThemeText.bodyText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTapDown: (_) async {
                          // Start listening when the button is pressed
                          await _listen();
                          setState(() {
                            _question = _transcription;
                          });
                        },
                        onTapUp: (_) async {
                          // Stop listening when the button is released
                          await _speech.stop();
                          setState(() {
                            _question = _transcription;
                          });
                        },
                        onTapCancel: () async {
                          // Stop listening if the press is canceled (e.g., user drags away)
                          await _speech.stop();
                          setState(() {
                            _question = _transcription;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: ThemeColours.primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.all(
                              8), // Optional: Add padding for better UX
                          child: Icon(icon, color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 13),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        //see change
                        height: 40,
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
                              if (secondDropdownValue != 'None') {
                                modifiedQuestion +=
                                    'I am from $secondDropdownValue. Answer in the language $dropdownValue';
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
