# Flutter Web App

This project is Flutter Camera Web App that uses the Flutter Camera package to use the user's camera on the web.

## INSTRUCTIONS

### IMPORTANT: ENSURE THAT A CAMERA IS AVAILABLE ON THE DEVICE THAT IS BEING USED FOR TESTING

1. In order to run this Flutter project, please first install flutter from https://docs.flutter.dev/get-started/install/windows.
2. After Flutter is installed, please resolve any Flutter dependencies issues with ***flutter doctor*** command; follow any instructions presented until Flutter can be run.
3. Open a terminal at the root of the Flutter project at **\\emotion_recognition_webapp** and run ***flutter run -d chrome --web-browser-flag "--disable-web-security"***.
4. Open the Chrome browser, allow the Flutter app access to the camera.
5. Ensure the Flask API is being run at the same time on localhost:5000
6. Test the app

## Dependencies

All the  dependencies required for this project are contained in the ***pubspec.yaml*** file found in the root of the Flutter project. When running the project for the first time, Flutter will automatically run ***flutter pub get*** to install all these dependencies. In case the dependencies are not automatically downloaded, run ***flutter pub get*** before running the Flutter project. The list of dependencies with the specific versions are as below:

1. provider: ^6.0.0
2. path_provider:
3. camera:
4. path:
5. camera_web: ^0.3.1+2
6. cross_file_image: ^1.0.0
7. http_parser: ^4.0.2
8. http:
9. dcdg:

## Notes

### Firebase Files

Inside the flutter projects, there are several Firebase config files that are used for the configuration when uploading this project to Firebase hosting.

### DCDG & PlantUML

The package DCDG is used to generate a PlantUML file of the classes contained in the Flutter project. This PlantUML file was converted into a PNG file and can be found in ***emotion_recognition_webapp\\out\\PlantUML\\PlantUML.png***
