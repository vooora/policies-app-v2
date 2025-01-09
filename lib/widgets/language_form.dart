import 'package:flutter/material.dart';
import 'package:policies_new/data/prompts.dart';
import 'package:policies_new/screens/state_screen.dart';
import 'package:policies_new/utils.dart';
import 'package:policies_new/widgets/filledbutton.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> list = <String>['English', 'हिन्दी', 'తెలుగు', 'தமிழ்'];



class LanguageForm extends StatefulWidget{
  const LanguageForm({super.key});
  @override
  State<LanguageForm> createState() => _LanguageFormState();
}

class _LanguageFormState extends State<LanguageForm> {
  String dropdownValue = list.first;
  @override
  void initState() {
    super.initState();
    //_loadLanguagePreference();
  }
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dropdownValue = prefs.getString('selectedLanguage') ?? list.first;
    });
  }

  
String getLanguageInEnglish(String language) {
  switch (language) {
    case 'English':
      return 'English';
    case 'हिन्दी':
      return 'Hindi';
    case 'తెలుగు':
      return 'Telugu';
    case 'தமிழ்':
      return 'Tamil';
    default:
      return 'English'; // Default to English if no match found
  }
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
  Future<void> _saveLanguagePreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
  }
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                children: [
                  Text(prompts[getLanguageNum(getLanguageInEnglish(dropdownValue))].title2, style: ThemeText.titleText2),
                  const SizedBox(height: 10),
                  Text('(Aఆआஆ)', style: ThemeText.titleText2),
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5)),
                        label: Text(prompts[getLanguageNum(getLanguageInEnglish(dropdownValue))].label1,
                            style: ThemeText.bodyText)),
                    value: dropdownValue,
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                    
                      _saveLanguagePreference(getLanguageInEnglish(value!));
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 30,),
                  IconButton.filled(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                      return StateScreen();
                    }));
                  }, icon: Icon(Icons.arrow_forward),style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          backgroundColor: MaterialStateProperty.all(Colors.teal)),
    )
                  ]
                  )
                  ))
                  )
                  ]);
  }
}