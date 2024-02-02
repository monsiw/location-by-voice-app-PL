# Location by Voice App

Location by Voice is a Flutter mobile application that allows users to check their current location and find nearby places using voice commands. The app utilizes speech-to-text and text-to-speech functionalities for a user-friendly experience.
The application was created for blind/visually impaired people to help them find their way/be sure about
the place where they are currently located by accepting a voice command (“gdzie jestem”) and providing the nearest one
object relative to the user's location and approximate time to reach it.
## Table of Contents
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [API_KEY Configuration](#api_key-configuration)
- [Language Configuration](#language-configuration)
- [APK Generation](#apk-generation)
- [Installing the APK on an Android Device](#installing-the-apk-on-an-android-device)
  - [Note]
- [Documentation](#documentation)
    - [Developer Documentation]
    - [API Documentation]
- [License](#license)

### Features
- Check current location by voice command
- Find nearby places and get estimated travel time using Google Maps API
- Speech-to-text and text-to-speech functionalities

### Getting Started

#### Prerequisites
- Flutter SDK installed
- Android Studio or VS Code
- Google Maps API key
#### Installation
1. **Clone the repository:**
    ```bash
    git clone https://github.com/monsiw/location-by-voice.git
    ```
2. **Navigate to the project directory:**
    ```bash
    cd location-by-voice
    ```
3. **Install dependencies:**
    ```bash
    flutter pub get
    ```
4. **Run the app:**
    ```bash
    flutter run
    ```
    
### Usage
- Launch the app on your mobile device
- Press the microphone button to initiate voice commands
- Use command "gdzie jestem"

### API_KEY Configuration
**Android** <br>
In your project folder, go to android/app/src/main/AndroidManifest.xml:
  ```xml
  <meta-data android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY"/>
  ```
**iOS** <br>
In your project folder, go to ios/Runner/Info.plist and enter the following code snippet:
  ```xml
  <key>API_KEY_NAME</key>
  <string>YOUR_API_KEY</string>
  ```
In the void _onSpeechResult(result) function:
  ```dart
  final String apiKey = 'YOUR_API_KEY';
  ```
In the function Future<Place?> _findNearestPlaceWithTravelTime(Position userLocation, List<Place> places) async:
  ```dart
  int travelTime = await getEstimatedTravelTime('YOUR_API_KEY', place);
  ```
In the Future<List<Place>> getNearbyPlaces(Position userLocation) async function:
  ```dart
  final String apiKey = 'YOUR_API_KEY';
  ```
### Language Configuration

To switch the language of the voice commands and notifications from Polish (PL) to English (EN), follow these steps:

1. Open the `lib/pages/find_location.dart` file in your preferred code editor

2. Locate the line where the selected locale ID is defined. It should look like this:
   ```dart
   final String _selectedLocaleId = 'pl-PL';
3. Change the locale ID to 'en-US' to set the language to English:
   ```dart
    final String _selectedLocaleId = 'en-US';
4. Update the voice command trigger to English. Find the block of code that checks for a specific command, such as:
   ```dart
    if (_wordsSpoken.toLowerCase().contains("gdzie jestem")) {
5. Change the command to the English equivalent:
   ```dart
    if (_wordsSpoken.toLowerCase().contains("where am I")) {
6. Save the changes to the file
Now, the app will respond to voice commands in English. Feel free to customize other parts of the code to fit your preferences.
Make sure to replace 'en-US' and 'where am I' with the specific language/locale and command you prefer.

### APK Generation

1. Open a terminal window

2. Navigate to the root directory of your Flutter project using the `cd` command:
    ```bash
    cd /path/to/your/project
    ```

3. Run the following command to build the release APK:
    ```bash
    flutter build apk --release
    ```

4. Once the build process completes, you can find the generated APK file in the `build/app/outputs/flutter-apk/` directory. The APK file will be named `app-release.apk`

5. Transfer the generated APK file to your Android device or distribute it as needed

### Installing the APK on an Android Device

1. Enable "Install from Unknown Sources" on your Android device:
    - Open **Settings**
    - Navigate to **Security** or **Biometrics and Security**
    - Enable the **Install Unknown Apps** or **Install from Unknown Sources** option for the file manager you'll use to install the APK

2. Transfer the APK file to your Android device using a USB cable or any preferred method

3. Open the file manager on your Android device and navigate to the location where you copied the APK file

4. Tap on the APK file to begin the installation process

5. Follow the on-screen instructions to complete the installation

6. Once the installation is complete, you can find and launch your app from the device's app drawer

#### Note
- The `--release` flag ensures that you are building a release APK, which is optimized for performance
- You may need to adjust security settings on your Android device to allow installations from unknown sources
- If you encounter any issues during the build process, refer to the [Flutter documentation](https://flutter.dev/docs/deployment/android) for troubleshooting and additional options
Make sure to replace `/path/to/your/project` with the actual path to your Flutter project

### Documentation
#### Developer Documentation
- [Speech-to-Text Package (stt)](https://pub.dev/packages/speech_to_text)
- [Text-to-Speech Package (flutter_tts)](https://pub.dev/packages/flutter_tts)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)

#### API Documentation
- [Google Maps API](https://developers.google.com/maps/documentation)

### License
This project is licensed under the MIT License
