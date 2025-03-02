import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TypingGamePage extends StatefulWidget {
  const TypingGamePage({Key? key}) : super(key: key);

  @override
  _TypingGamePageState createState() => _TypingGamePageState();
}

class _TypingGamePageState extends State<TypingGamePage> {
  final List<String> wordList = [
    "flutter",
    "développement",
    "mobile",
    "desktop",
    "application",
    "rapide",
    "performance",
    "widget",
    "interface",
    "responsive",
    "code",
    "dart",
    "programmation",
    "open-source",
    "puissant",
    "efficace",
    "design",
    "matériel",
    "framework",
    "flexible",
  ];

  String textToType = "";
  String userInput = "";
  bool gameStarted = false;
  bool gameFinished = false;
  double wpm = 0.0;
  double accuracy = 100.0;

  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    generateRandomText();
  }

  void generateRandomText() {
    int wordCount = 6 + random.nextInt(5);
    textToType = List.generate(
      wordCount,
      (index) => wordList[random.nextInt(wordList.length)],
    ).join(" ");
  }

  void startTimer() {
    if (!gameStarted) {
      setState(() {
        gameStarted = true;
        stopwatch.start();
      });

      timer = Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
        setState(() {});
      });
    }
  }

  void restartGame() {
    setState(() {
      generateRandomText();
      userInput = "";
      wpm = 0.0;
      accuracy = 100.0;
      gameFinished = false;
      gameStarted = false;
      stopwatch.reset();
    });
  }

  List<TextSpan> buildTextSpans() {
    List<TextSpan> spans = [];

    for (int i = 0; i < textToType.length; i++) {
      Color color = Colors.grey;
      if (i < userInput.length) {
        color = (userInput[i] == textToType[i]) ? Colors.green : Colors.red;
      }
      spans.add(
        TextSpan(
          text: textToType[i],
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return spans;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            _handleKeyPress(event);
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Affichage du texte à taper
                RichText(text: TextSpan(children: buildTextSpans())),
                const SizedBox(height: 20),
                if (gameFinished)
                  Column(
                    children: [
                      // Affichage des résultats
                      Text(
                        'Vitesse: ${wpm.toStringAsFixed(2)} WPM',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Précision: ${accuracy.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.black,
                          size: 40,
                        ),
                        onPressed: restartGame,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (userInput.isNotEmpty) {
        setState(() {
          userInput = userInput.substring(0, userInput.length - 1);
        });
      }
    } else if (event.character != null && event.character!.isNotEmpty) {
      setState(() {
        userInput += event.character!;
      });
    }

    startTimer();

    if (userInput == textToType) {
      stopwatch.stop();
      timer?.cancel();
      setState(() {
        gameStarted = false;
        gameFinished = true;

        double minutes = stopwatch.elapsed.inSeconds / 60;
        int wordCount = textToType.split(" ").length;
        wpm = (minutes > 0) ? (wordCount / minutes) : 0;

        int correctChars = 0;
        for (int i = 0; i < userInput.length; i++) {
          if (i < textToType.length && userInput[i] == textToType[i]) {
            correctChars++;
          }
        }
        accuracy = (correctChars / textToType.length) * 100;
      });
    }
  }
}
