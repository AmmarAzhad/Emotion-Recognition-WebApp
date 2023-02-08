import 'dart:html';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyAppState()),
        ChangeNotifierProvider(create: (context) => Emotion()),
      ],
      child: MaterialApp(
        title: 'Mood Tracker',
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.sourceCodeProTextTheme(
            Theme.of(context).textTheme,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 144, 224, 239)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class Emotion extends ChangeNotifier {
  final emotions = [
    'HAPPY',
    'SAD',
    'ANGRY',
  ];

  late var randomEmotion = (emotions..shuffle()).first;

  void getEmotion() {
    randomEmotion = (emotions..shuffle()).first;
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var emotionState = context.watch<Emotion>();
    var emotionStr = emotionState.randomEmotion;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            titleText(),
            TitleCard(emotion: emotionStr),
            Camera(),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.photo_camera),
                    label: Text(
                      'Capture',
                      style: TextStyle(fontSize: 20),
                    )),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    emotionState.getEmotion();
                  },
                  icon: Icon(Icons.add_reaction),
                  label: Text(
                    'Detect',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Camera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 5, color: Color.fromARGB(255, 144, 224, 239)),
            left: BorderSide(width: 5, color: Color.fromARGB(255, 144, 224, 239)),
            right: BorderSide(width: 5, color: Color.fromARGB(255, 144, 224, 239)),
            bottom: BorderSide(width: 5, color: Color.fromARGB(255, 144, 224, 239)),
          ),
          borderRadius: BorderRadius.all(Radius.circular(15))),
      margin: const EdgeInsets.all(10.0),
      //color: Colors.grey,
      width: 500,
      height: 500,
    );
  }
}

Text titleText() {
  return Text(
    'MOOD TRACKER',
    style: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w300,
    ),
  );
}

class TitleCard extends StatelessWidget {
  const TitleCard({
    super.key,
    required this.emotion,
  });

  final String emotion;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Center(
      child: Card(
        color: theme.colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 10),
          child: Text(
            emotion,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              color: theme.colorScheme.onPrimary,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
