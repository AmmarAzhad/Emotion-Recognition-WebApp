import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  final firstCamera = cameras.first;

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
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

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
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
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
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
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
  Camera({
    super.key,
    required this.camera,
  });
  final CameraDescription camera;
  @override
  Widget build(BuildContext context) {
    return Container(
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
      height: 500,
      child: CameraScreen(camera: camera),
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
