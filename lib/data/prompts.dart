import 'package:policies_new/data/states.dart';
import 'package:policies_new/models/FormText.dart';

const List<FormText> prompts = [
  FormText(key:0,title: "ASK A QUESTION", title1: "SELECT A STATE", title2: "SELECT A LANGUAGE", label1: "Choose Input Language", label2: "Choose Your State", label3: "Enter your question", prompt2: englishStates),
   FormText(key:1,title: "प्रश्न पूछें",title1: "राज्य चुनें" ,title2: "भाषा चुनें",label1: "अपनी भाषा चुनें", label2: "अपना राज्य चुनें", label3: "अपना प्रश्न दर्ज करें", prompt2: hindiStates),
    FormText(key:2,title: "ప్రశ్న అడగండి", title1: "రాష్ట్రాన్ని ఎంచుకోండి", title2: "భాషను ఎంచుకోండి", label1: "మీ భాషను ఎంచుకోండి", label2: "మీ రాష్ట్రాన్ని ఎంచుకోండి", label3: "మీ ప్రశ్నను నమోదు చేయండి", prompt2: teluguStates),
     FormText(key:3,title: "ஒரு கேள்வியைக் கேளுங்கள்", title1: "மாநிலத்தை தேர்வு செய்யவும்", title2: "மொழியை தேர்வு \n      செய்யவும்", label1: "உங்கள் மொழியை தேர்வு செய்யவும்", label2: "உங்கள் மாநிலத்தைத் தேர்ந்தெடுக்கவும்", label3: "உங்கள் கேள்வியை உள்ளிடவும்", prompt2: tamilStates)

];