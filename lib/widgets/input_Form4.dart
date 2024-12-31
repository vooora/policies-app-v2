import 'package:flutter/material.dart';
import 'package:policies_new/screens/answer_screen.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:policies_new/models/Response.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InputForm extends StatefulWidget {
  const InputForm({super.key});

  @override
  State<InputForm> createState() => _InputFormState();
}

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

const List<String> list = <String>['English', 'Hindi', 'Telugu', 'Tamil'];

class _InputFormState extends State<InputForm> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  String? _selectedLocale;

  List<String> _locales = [];
  String _transcription = ''; // Holds the final transcribed text
  TextEditingController _questionController = TextEditingController();

  String secondDropdownValue = secondList.first;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Initialize speech and fetch available locales
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (_speechEnabled) {
      var locales = await _speechToText.locales();
      setState(() {
        _locales = locales.map((locale) => locale.localeId).toList();
        if (_locales.isNotEmpty) {
          _selectedLocale = _locales[0]; // Default to the first locale
        }
      });
    }
  }

  /// Start speech recognition with the selected locale
  void _startListening() async {
    if (_selectedLocale != null) {
      setState(() => _isListening = true);
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: _selectedLocale!,
      );
    }
  }

  /// Stop speech recognition
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  /// Callback when speech recognition results are available
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _transcription = _lastWords; // Update transcription with recognized words
      _questionController.text = _transcription; // Reflect in the input field
    });
  }

  Future<CustomResponse> fetchResponse(String question) async {
    print(question);
    var res = await http.post(
      Uri.parse('https://policies-app-backend-nlvo.onrender.com'),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      encoding: Encoding.getByName('utf-8'),
      body: {"body": question},
    );
    final body = jsonDecode(res.body);
    if (body == "null") {
      return const CustomResponse(type: "null", body: {"null": "null"});
    }
    final resp = CustomResponse(type: body['type'], body: body['body']);
    return resp;
  }

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Ask a question:',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            const SizedBox(height: 13),
            DropdownButtonFormField(
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                label: Text("Choose Input State"),
              ),
              value: secondDropdownValue,
              onChanged: (String? value) {
                setState(() {
                  secondDropdownValue = value!;
                });
              },
              items: secondList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 10.9)),
                );
              }).toList(),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _speechToText.isListening
                      ? '$_lastWords'
                      : _speechEnabled
                          ? 'Tap the microphone to start listening...'
                          : 'Speech not available',
                ),
              ),
            ),
            // Dropdown to select language
            Container(
              padding: EdgeInsets.all(16),
              child: DropdownButton<String>(
                value: _selectedLocale,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLocale = newValue;
                  });
                },
                items: _locales.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 40,
                  width: 115,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: IconButton(
                      icon: !_loading
                          ? const Icon(Icons.arrow_forward_outlined,
                              color: Colors.white)
                          : const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                        });

                        // Use the transcribed text as the question
                        String modifiedQuestion = _transcription;
                        if (secondDropdownValue != 'None') {
                          modifiedQuestion +=
                              ' I am from $secondDropdownValue.';
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
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) {
                              return AnswerScreen(res: res);
                            }),
                          );
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
      floatingActionButton: FloatingActionButton(
        onPressed:
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
