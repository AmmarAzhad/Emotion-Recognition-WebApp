import 'dart:async';
import 'package:emotion_recognition_webapp/detect_emotion.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:camera_web/camera_web.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras[0];
  runApp(MyApp(
    camera: firstCamera,
  ));
}

// A screen that allows users to take a picture using a given camera.
class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.max,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Center(child: CameraPreview(_controller));
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();
            var data = await fetchdata(image);

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  image: data,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final Uint8List image;
  const DisplayPictureScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detected Emotion')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.memory(image),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.camera,
  });
  final CameraDescription camera;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyAppState()),
        ChangeNotifierProvider(create: (context) => Emotion()),
        ChangeNotifierProvider(create: (context) => Quotes()),
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
        home: MyHomePage(camera: camera),
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

class Quotes extends ChangeNotifier {
  final quotes = [
    'Don`t give up when dark times come. The more storms you face in life, the stronger you`ll be. Hold on. Your greater is coming.',
    'The sky is everywhere, it begins at your feet.',
    'Let us be of good cheer, however, remembering that the misfortunes hardest to bear are those which never come.',
    'Stop feeling sorry for yourself and you will be happy.',
  ];

  late var randomQuote = (quotes..shuffle()).first;

  void getQuote() {
    randomQuote = (quotes..shuffle()).first;
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
  MyHomePage({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;
  @override
  Widget build(BuildContext context) {
    var emotionState = context.watch<Emotion>();
    var emotionStr = emotionState.randomEmotion;
    var quoteState = context.watch<Quotes>();
    var quoteStr = quoteState.randomQuote;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            titleText(),
            TitleCard(emotion: emotionStr),
            Camera(camera: camera),
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
                    quoteState.getQuote();
                  },
                  icon: Icon(Icons.add_reaction),
                  label: Text(
                    'Detect',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            QuoteCard(quote: quoteStr)
          ],
        ),
      ),
    );
  }
}

class Camera extends StatelessWidget {
  Camera({
    super.key,
    required this.camera,
  });
  final CameraDescription camera;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: double.infinity,
        ),
        decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: 7, color: Color.fromARGB(255, 144, 224, 239)),
              left: BorderSide(width: 7, color: Color.fromARGB(255, 144, 224, 239)),
              right: BorderSide(width: 7, color: Color.fromARGB(255, 144, 224, 239)),
              bottom: BorderSide(width: 7, color: Color.fromARGB(255, 144, 224, 239)),
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        margin: const EdgeInsets.all(10.0),
        //color: Colors.grey,
        width: 338,
        height: 400,
        child: CameraScreen(camera: camera),
      ),
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

class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
  });

  final String quote;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Center(
      child: Card(
        color: theme.colorScheme.primary,
        child: SizedBox(
          width: 600,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Text(
              quote,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                color: theme.colorScheme.onPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
