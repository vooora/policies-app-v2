import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:policies_new/data/prompts.dart';
import 'package:policies_new/screens/question_screen.dart';
import 'package:policies_new/utils.dart';
import 'package:policies_new/widgets/input_form3.dart';
import 'package:shared_preferences/shared_preferences.dart';

String translateStateToEnglish(String stateName, List<String> states){
  int idx = states.indexOf(stateName);
  return translateToLanguage(idx, 0);
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
String translateToLanguage(int idx, int langCode){

  return prompts[langCode].prompt2[idx];
}

class StateForm extends StatefulWidget{
  const StateForm({super.key});

  @override
  State<StateForm> createState() => _StateFormState();
}

class _StateFormState extends State<StateForm> {


  String secondDropdownValue = secondList.first;
  String selectedLanguage = "English";
  
List<String> l1 = secondList;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadLanguagePreference();
   
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
     selectedLanguage = prefs.getString('selectedLanguage') ?? "English" ;
    });
  }
    Future<void> _saveStatePreference(String state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedState', state);

    print("State set to $state");
  }

  @override
  Widget build(BuildContext context) {
   List<String> secondList = [
    'None',
  translateToLanguage(1,getLanguageNum(selectedLanguage)),
translateToLanguage(2,getLanguageNum(selectedLanguage)),
translateToLanguage(3,getLanguageNum(selectedLanguage)),
translateToLanguage(4,getLanguageNum(selectedLanguage)),
translateToLanguage(5,getLanguageNum(selectedLanguage)),
translateToLanguage(6,getLanguageNum(selectedLanguage)),
translateToLanguage(7,getLanguageNum(selectedLanguage)),
translateToLanguage(8,getLanguageNum(selectedLanguage)),
translateToLanguage(9,getLanguageNum(selectedLanguage)),
translateToLanguage(10,getLanguageNum(selectedLanguage)),
translateToLanguage(11,getLanguageNum(selectedLanguage)),
translateToLanguage(12,getLanguageNum(selectedLanguage)),
translateToLanguage(13,getLanguageNum(selectedLanguage)),
translateToLanguage(14,getLanguageNum(selectedLanguage)),
translateToLanguage(15,getLanguageNum(selectedLanguage)),
translateToLanguage(16,getLanguageNum(selectedLanguage)),
translateToLanguage(17,getLanguageNum(selectedLanguage)),
translateToLanguage(18,getLanguageNum(selectedLanguage)),
translateToLanguage(19,getLanguageNum(selectedLanguage)),
translateToLanguage(20,getLanguageNum(selectedLanguage)),
translateToLanguage(21,getLanguageNum(selectedLanguage)),
translateToLanguage(22,getLanguageNum(selectedLanguage)),
translateToLanguage(23,getLanguageNum(selectedLanguage)),
translateToLanguage(24,getLanguageNum(selectedLanguage)),
translateToLanguage(25,getLanguageNum(selectedLanguage)),
translateToLanguage(26,getLanguageNum(selectedLanguage)),
translateToLanguage(27,getLanguageNum(selectedLanguage)),
translateToLanguage(28,getLanguageNum(selectedLanguage))
];

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
                  Text(prompts[getLanguageNum(selectedLanguage)].title1, style: ThemeText.titleText2),
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5)),
                        label: Text(prompts[getLanguageNum(selectedLanguage)].label2,
                            style: ThemeText.bodyText)),
                    value: secondDropdownValue,
                    onChanged: (String? value) {
                      setState(() {
                        secondDropdownValue = value!;
                         
                      });
                      _saveStatePreference(translateStateToEnglish(secondDropdownValue, secondList));
                    },
                    items: secondList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 10.9)),
                      );
                    }).toList(),
                  ),
             
                  SizedBox(height: 30,),
                  IconButton.filled(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                      return QuestionScreen();
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