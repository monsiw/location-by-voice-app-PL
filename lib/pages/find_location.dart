import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FindLocationScreen extends StatefulWidget
{
  const FindLocationScreen({Key? key}) : super(key: key);
  @override
  _FindLocationScreenState createState() => _FindLocationScreenState();
}

class Place
{
  final String name;
  final LatLng location;
  Place({required this.name, required this.location});
}

class _FindLocationScreenState extends State<FindLocationScreen> with TickerProviderStateMixin
{
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  final String _selectedLocaleId = 'pl-PL';
  bool _speechAvailable = false;

  bool _isPulsing = false;
  bool _isAnimating = false;
  late AnimationController _pulsingController;
  late Animation<double> _pulsingAnimation;
  String address = '';

  @override
  void initState()
  {
    super.initState();
    initSpeech();
    _configureTTS();
    _pulsingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _pulsingAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulsingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose()
  {
    _pulsingController.dispose();
    super.dispose();
  }

  void _startPulsingAnimation()
  {
    _pulsingController.repeat(reverse: true);
    setState(() {
      _isPulsing = true;
      _isAnimating = true;});
  }

  void _resetPulsingAnimation()
  {
    if (_isAnimating)
    {
      _pulsingController.reset();
      setState(() {
        _isPulsing = false;
        _isAnimating = false;});
    }
    else
    {
      _pulsingController.stop();
    }
  }

  Future<void> _configureTTS() async
  {
    await flutterTts.setLanguage('pl-PL');
  }

  void initSpeech() async
  {
    _speechAvailable = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async
  {
    await _speechToText.listen(onResult: _onSpeechResult, localeId: _selectedLocaleId);
    setState((){
      _speechEnabled = true;
      _confidenceLevel = 0;});
  }

  void _stopListening() async
  {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result)
  {
    setState((){
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;});
    if (_wordsSpoken.toLowerCase().contains("gdzie jestem"))
    {
      _startPulsingAnimation();
      _getUserCurrentLocation().then((value) async {
        final GoogleMapController controller = await _controller.future;
        CameraPosition _kGooglePlex = CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 16,);
        controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex),);
        List<Place> nearbyPlaces = await getNearbyPlaces(value);
        if (nearbyPlaces.isNotEmpty)
        {
          Place? nearestPlace = await _findNearestPlaceWithTravelTime(value, nearbyPlaces);
          if (nearestPlace != null)
          {
            final String apiKey = 'API_KEY';
            int estimatedTime = await getEstimatedTravelTime(apiKey, nearestPlace);
            await flutterTts.speak("Jesteś w pobliżu ${nearestPlace.name}. Szacowany czas dotarcia ${estimatedTime ~/ 60} minut");
          }
          else
          {
            await flutterTts.speak("Nie znaleziono pobliskich miejsc");
          }
        }
      });
    }
  }

  Future<Place?> _findNearestPlaceWithTravelTime(Position userLocation, List<Place> places) async
  {
    Place? nearestPlace;
    int? minTravelTime;
    for (Place place in places)
    {
      int travelTime = await getEstimatedTravelTime('API_KEY', place);
      if (minTravelTime == null || travelTime < minTravelTime)
      {
        minTravelTime = travelTime;
        nearestPlace = place;
      }
    }
    return nearestPlace;
  }

  final Completer<GoogleMapController> _controller = Completer();

  Future<Position> _getUserCurrentLocation() async
  {
    await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) {print(error.toString());});
    return await Geolocator.getCurrentPosition();
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(50.284405, 18.671257),
    zoom: 8.0,);

  Future<List<Place>> getNearbyPlaces(Position userLocation) async
  {
    final String apiKey = 'API_KEY';
    final String apiUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    final double radius = 500;
    final Uri uri = Uri.parse('$apiUrl?location=${userLocation.latitude},${userLocation.longitude}&radius=$radius&key=$apiKey',);
    final http.Response response = await http.get(uri);
    if (response.statusCode == 200)
    {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'OK')
      {
        final List<dynamic> results = data['results'];
        List<Place> places = results.map((result){
          final String name = result['name'];
          final double lat = result['geometry']['location']['lat'];
          final double lng = result['geometry']['location']['lng'];
          final LatLng location = LatLng(lat, lng);
          return Place(name: name, location: location);
        }).toList();
        return places;
      }
      else
      {
        throw Exception('Error: ${data['status']}');
      }
    }
    else
    {
      throw Exception('Failed to load data');
    }
  }

  Future<int> getEstimatedTravelTime(String apiKey, Place destination) async
  {
    try
    {
      Position userLocation = await _getUserCurrentLocation();
      final String apiUrl = 'https://maps.googleapis.com/maps/api/directions/json';
      final String mode = 'walking';
      final Uri uri = Uri.parse(
          '$apiUrl?origin=${userLocation.latitude},${userLocation
              .longitude}&destination=${destination.location
              .latitude},${destination.location
              .longitude}&mode=$mode&key=$apiKey');
      final http.Response response = await http.get(uri);
      if (response.statusCode == 200)
      {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'OK')
        {
          final int durationInSeconds = data['routes'][0]['legs'][0]['duration']['value'];
          return durationInSeconds;
        }
        else
        {
          throw Exception('Error: ${data['status']}');
        }
      }
      else
      {
        throw Exception('Failed to load data');
      }
    }
    catch (e)
    {
      throw Exception('Failed to get user location: $e');
    }
  }

  void _speakInformation()
  {
    flutterTts.speak('Naciśnij przycisk mikrofonu i wydaj komende głosową');
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.indigo,
        title: Text('Sprawdź swoją lokalizację',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            color: Colors.white,
            onPressed: () {_speakInformation();},
          ),
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildGoogleMapWidget(),
            Column(
              children: [
                if (_speechToText.isNotListening && _confidenceLevel > 0)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 100,
                    ),
                    child: Text(
                      "Dokładność: ${(_confidenceLevel * 100).toStringAsFixed(
                          1)}%",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.indigo,
                      ),
                    ),
                  )
              ],
            ),
            Positioned(
              bottom: 210.0,
              child: Transform.translate(
                offset: Offset(0.0, 0.0),
                child: Container(
                  width: 150.0,
                  height: 150.0,
                  child: FloatingActionButton(
                    onPressed: () {
                      if (_speechToText.isListening)
                      {
                        _stopListening();
                        _resetPulsingAnimation();
                      }
                      else
                      {
                        _startListening();
                        _startPulsingAnimation();
                      }
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    child: AnimatedBuilder(
                      animation: _pulsingController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulsingAnimation.value,
                          child: CircleAvatar(
                            backgroundColor: Colors.indigo,
                            radius: 120.0,
                            child: Icon(
                              _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                              size: 110.0,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            )],
        ),
      ),
    );
  }

  Widget _buildGoogleMapWidget()
  {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _kGooglePlex,
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {_controller.complete(controller);},
        ),
      ],
    );
  }
}
