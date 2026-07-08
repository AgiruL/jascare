import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:http/http.dart' as http; // ✅ Added package for network uploads
import '../models/weather_data.dart';
import '../widgets/weather_overlay.dart';
import 'main_navigation_screen.dart';
import 'dart:convert'; // Required for jsonEncode()
import 'package:shared_preferences/shared_preferences.dart'; // Required for disk writes
import '../services/api_service.dart';
import '../services/cloudinary_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CampusMapScreen extends StatefulWidget {
  final String currentWeather;
  final bool isFullscreen;
  final ValueChanged<String> onWeatherChanged;
  final VoidCallback onToggleFullscreen;
  final List<CustomIncident> incidentList;
  final Function(CustomIncident) onAddIncident;

  const CampusMapScreen({
    super.key,
    required this.currentWeather,
    required this.isFullscreen,
    required this.onWeatherChanged,
    required this.onToggleFullscreen,
    required this.incidentList,
    required this.onAddIncident,
  });

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();

}

class _CampusMapScreenState extends State<CampusMapScreen> {
  bool _isTimelineExpanded = false;
  File? _attachedImage; 
  final ImagePicker _picker = ImagePicker();
  GoogleMapController? _mapController;
  List<dynamic> _locations = [];
  StreamSubscription<Position>? _locationStreamSubscription;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  static const LatLng _perpustakaanJasin = LatLng(2.2104, 102.4516);
  LatLng _userDeviceLocationPoint = _perpustakaanJasin; 
  String _addressTextDisplay = "Locating device... GPS data auto-assigned";
  
  String _selectedCategory = "Crime"; 
  bool _isMapLocationLayerReady = false; 
  bool _isUploading = false; // ✅ Added upload progress state indicator tracking flag

  @override
    void initState() {
      super.initState();
      _startSmoothLocationStreaming();
      _loadLocations();
    }

    Future<void> _loadLocations() async {
      final data = await ApiService.getLocations();

      if (!mounted) return;

      setState(() {
        _locations = data;
      });

      print("========== LOCATIONS ==========");
      print(data);
      print("===============================");
    
  }

  @override
  void dispose() {
    _locationStreamSubscription?.cancel();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _startSmoothLocationStreaming() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool opened = await Geolocator.openLocationSettings();
      if (!opened) {
        setState(() => _addressTextDisplay = "Please turn on your phone's Location / GPS settings.");
        return;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _addressTextDisplay = "Location permission denied by user.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _addressTextDisplay = "Location permissions blocked in settings.");
      return;
    }

    setState(() {
      _isMapLocationLayerReady = true;
    });

    Position initialPos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _updateUserPositionState(initialPos);

    _locationStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 3)
    ).listen((Position position) {
      _updateUserPositionState(position);
    });
  }

  void _updateUserPositionState(Position position) {
    if (!mounted) return;
    LatLng newPoint = LatLng(position.latitude, position.longitude);
    
    setState(() {
      _userDeviceLocationPoint = newPoint;
      _addressTextDisplay = "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
    });

    _animateToUserLocation();
    _checkProximityDangerAlerts(newPoint);
  }

  void _animateToUserLocation() {
    _mapController?.animateCamera(CameraUpdate.newLatLng(_userDeviceLocationPoint));
  }

  void _checkProximityDangerAlerts(LatLng userLoc) {
    for (var incident in widget.incidentList) {
      if (incident.isActive) {
        double distanceInMeters = Geolocator.distanceBetween(
          userLoc.latitude, userLoc.longitude,
          incident.latitude, incident.longitude
        );

        if (distanceInMeters <= 100.0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("🚨 WARNING: Active ${incident.category} issue detected nearby within ${distanceInMeters.toStringAsFixed(0)}m!"),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
          );
          break; 
        }
      }
    }
  }

  Set<Marker> _buildMapMarkers() {
      Set<Marker> markers = {};

      // Incident markers
      for (var incident in widget.incidentList) {
        if (incident.isActive) {
          double colorHue = incident.category == "Crime"
              ? BitmapDescriptor.hueViolet
              : BitmapDescriptor.hueOrange;

          markers.add(
            Marker(
              markerId: MarkerId("incident_${incident.id}"),
              position: LatLng(incident.latitude, incident.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(colorHue),
              infoWindow: InfoWindow(
                title: incident.title,
                snippet: incident.description,
              ),
            ),
          );
        }
      }

      // Admin location markers from Laravel API
      for (var location in _locations) {
        final double lat = double.tryParse(location['latitude'].toString()) ?? 0.0;
        final double lng = double.tryParse(location['longitude'].toString()) ?? 0.0;

        if (lat == 0.0 || lng == 0.0) continue;

        markers.add(
          Marker(
            markerId: MarkerId("location_${location['id']}"),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: location['name'] ?? 'Campus Location',
              snippet: location['type'] ?? 'Location',
            ),
          ),
        );
      }

      return markers;
    }

  Set<Circle> _buildProximityCircles() {
    return {
      Circle(
        circleId: const CircleId("user_proximity_zone"),
        center: _userDeviceLocationPoint,
        radius: 100, 
        fillColor: Colors.blue.withOpacity(0.12),
        strokeColor: Colors.blue.withOpacity(0.4),
        strokeWidth: 2,
      )
    };
  }

  String _getWeatherEmoji(String condition) {
    switch (condition) {
      case "windy": return "💨 Windy";
      case "rain": return "🌧️ Rain";
      case "night": return "🌙 Night";
      case "sunny":
      default: return "☀️ Sunny";
    }
  }

  // ✅ CLOUDINARY UPLOAD PIPELINE FUNCTION
  

  Future<void> _submitIncidentForm() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in the incident title"), backgroundColor: Colors.red)
      );
      return;
    }

    // Toggle loading states
    setState(() => _isUploading = true);
    String? finalCloudinaryUrl;

    if (_attachedImage != null) {
      // 🔄 CALL THE LOCAL UPLOAD METHOD: Route through the local Cloudinary upload pipeline
      finalCloudinaryUrl = await CloudinaryService.uploadIncidentImage(_attachedImage!.path);
      
      if (finalCloudinaryUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cloud storage upload dropped. Saving locally instead."), backgroundColor: Colors.orange)
        );
      }
    }

    final newReport = CustomIncident(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? "No notes" : _descController.text.trim(),
      latitude: _userDeviceLocationPoint.latitude,
      longitude: _userDeviceLocationPoint.longitude,
      category: _selectedCategory, 
      imagePath: finalCloudinaryUrl ?? _attachedImage?.path, 
      isActive: true,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> storedList = prefs.getStringList('local_incidents') ?? [];
      
      String jsonIncident = jsonEncode({
        'id': newReport.id,
        'title': newReport.title,
        'description': newReport.description,
        'latitude': newReport.latitude,
        'longitude': newReport.longitude,
        'category': newReport.category,
        'imagePath': newReport.imagePath,
        'isActive': newReport.isActive,
      });
      
      storedList.add(jsonIncident);
      await prefs.setStringList('local_incidents', storedList);
    } catch (e) {
      debugPrint("Failed to write persistence layer data: $e");
    }

    widget.onAddIncident(newReport);

    final user = FirebaseAuth.instance.currentUser;

    final username = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : (user?.email ?? "Guest");

    await ApiService.submitReport(
      username: username,
      incident: _selectedCategory,
      description: newReport.description,
      latitude: newReport.latitude,
      longitude: newReport.longitude,
      imageUrl: finalCloudinaryUrl,
    );
    
    _titleController.clear();
    _descController.clear();
    
    setState(() {
      _attachedImage = null;
      _isUploading = false;
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showReportIncidentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final bool isDark = widget.currentWeather != "sunny";
            final Color textCol = isDark ? Colors.white : const Color(0xFF1A233D);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24, left: 20, right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Report New Incident", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textCol)),
                    const SizedBox(height: 4),
                    Text("📍 Auto-Detected Location: $_addressTextDisplay", style: const TextStyle(fontSize: 11, color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    
                    Text("Select Type:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textCol)),
                    const SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 10.0,
                      runSpacing: 8.0,
                      children: [
                        ChoiceChip(
                          label: const Text("🔴 Crime / Theft"),
                          selected: _selectedCategory == "Crime",
                          onSelected: (val) { if (val) setModalState(() => _selectedCategory = "Crime"); },
                        ),
                        ChoiceChip(
                          label: const Text("🟠 Damaged Facility"),
                          selected: _selectedCategory == "Facility",
                          onSelected: (val) { if (val) setModalState(() => _selectedCategory = "Facility"); },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent.withAlpha(40), foregroundColor: Colors.blue),
                            onPressed: _isUploading ? null : () async {
                              final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                              if (file != null) setModalState(() => _attachedImage = File(file.path));
                            },
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text("Capture Image"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent.withAlpha(40), foregroundColor: Colors.purple),
                            onPressed: _isUploading ? null : () async {
                              final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                              if (file != null) setModalState(() => _attachedImage = File(file.path));
                            },
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Text("Upload File"),
                          ),
                        ),
                      ],
                    ),
                    if (_attachedImage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green, width: 2)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_attachedImage!, fit: BoxFit.cover),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      enabled: !_isUploading,
                      style: TextStyle(color: textCol),
                      decoration: const InputDecoration(labelText: "Incident Title", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descController,
                      enabled: !_isUploading,
                      style: TextStyle(color: textCol),
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: "Description & Specific Details", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    
                    // ✅ Dynamic submit button turns into loading circle indicator during cloud operations
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52), backgroundColor: const Color(0xFF6366F1)),
                      onPressed: _isUploading ? null : () async {
                        setModalState(() => _isUploading = true);
                        await _submitIncidentForm();
                      },
                      child: _isUploading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text("Submit Report", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.currentWeather != "sunny";
    final Color elementBgColor = isDark ? const Color(0xFF161625) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1A233D);
    final weatherConfig = WeatherConfig.getConfig(widget.currentWeather);

    int activeCrime = widget.incidentList.where((e) => e.category == "Crime" && e.isActive).length;
    int activeFacility = widget.incidentList.where((e) => e.category == "Facility" && e.isActive).length;
    int solvedCount = widget.incidentList.where((e) => !e.isActive).length;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.88 : 1.0,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(target: _perpustakaanJasin, zoom: 16.5),
                markers: _buildMapMarkers(),
                circles: _buildProximityCircles(), 
                myLocationEnabled: _isMapLocationLayerReady, 
                myLocationButtonEnabled: false, 
                compassEnabled: false,
                zoomControlsEnabled: false,
                padding: const EdgeInsets.only(bottom: 125),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  final now = DateTime.now();
                  final double timeAsDouble = now.hour + (now.minute / 60.0);
                  if (timeAsDouble >= 19.5 || timeAsDouble < 7.0 || widget.currentWeather == "rain") {
                    controller.setMapStyle(_darkMapStyleConfiguration);
                  }
                },
              ),
            ),
          ),
          
          Positioned.fill(
            child: IgnorePointer(
              child: WeatherOverlay(condition: widget.currentWeather),
            ),
          ),
          
          if (!widget.isFullscreen)
            Positioned(
              top: 45, left: 16, right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    color: elementBgColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("JasCare", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: textColor)),
                              Text("SMART SAFE CAMPUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade400, letterSpacing: 1)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(13), 
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getWeatherEmoji(widget.currentWeather),
                              style: TextStyle(color: isDark ? Colors.blueAccent.shade100 : Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => setState(() => _isTimelineExpanded = !_isTimelineExpanded),
                    child: Card(
                      color: elementBgColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(widget.currentWeather == "sunny" ? Icons.wb_sunny : widget.currentWeather == "windy" ? Icons.air : widget.currentWeather == "rain" ? Icons.thunderstorm : Icons.nightlight_round, color: Colors.purpleAccent, size: 28),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${weatherConfig.headerLabel}  ${weatherConfig.mainTemp}°C", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                                        Text("💧 Humidity: ${weatherConfig.humidity}%", style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(_isTimelineExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: textColor),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(weatherConfig.alertMessage, style: const TextStyle(fontSize: 12, color: Colors.orangeAccent, fontWeight: FontWeight.w500)),
                            if (_isTimelineExpanded) ...[
                              const Divider(height: 20),
                              Text("WEATHER TIMELINE — UITM JASIN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white38 : Colors.black38, letterSpacing: 0.5)),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: weatherConfig.timeline.map((item) {
                                    final bool isNow = item.timeOffset == "Now";
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isNow ? Colors.blue.withAlpha(38) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: isNow ? Colors.blue : Colors.transparent),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(item.timeOffset, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                                          const SizedBox(height: 4),
                                          Icon(item.icon, size: 20, color: isDark ? Colors.white : Colors.black87),
                                          const SizedBox(height: 4),
                                          Text("${item.temp}°", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                                          Text(item.label, style: TextStyle(fontSize: 9, color: isDark ? Colors.white38 : Colors.black38)),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(color: elementBgColor, borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("🔴 $activeCrime Crime", style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text("🟠 $activeFacility Facility", style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text("🟢 $solvedCount Solved", style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.add_a_photo_outlined, size: 20),
                        label: const Text("Scan / Mark Incident", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        onPressed: _showReportIncidentSheet,
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    FloatingActionButton(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onPressed: _animateToUserLocation,
                      child: const Icon(Icons.my_location_rounded, size: 22),
                    ),
                    const SizedBox(width: 8),
                    
                    FloatingActionButton(
                      backgroundColor: elementBgColor,
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onPressed: widget.onToggleFullscreen,
                      child: Icon(widget.isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded, size: 26),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

const String _darkMapStyleConfiguration = '''
[
  { "elementType": "geometry", "stylers": [{ "color": "#212121" }] },
  { "elementType": "labels.icon", "stylers": [{ "visibility": "off" }] },
  { "elementType": "labels.text.fill", "stylers": [{ "color": "#757575" }] },
  { "elementType": "labels.text.stroke", "stylers": [{ "color": "#212121" }] },
  { "featureType": "administrative", "elementType": "geometry", "stylers": [{ "color": "#757575" }] },
  { "featureType": "poi", "elementType": "geometry", "stylers": [{ "color": "#121212" }] },
  { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [{ "color": "#a5a5a5" }] },
  { "featureType": "road", "elementType": "geometry.fill", "stylers": [{ "color": "#2c2c2c" }] },
  { "featureType": "road", "elementType": "labels.text.fill", "stylers": [{ "color": "#8a8a8a" }] },
  { "featureType": "water", "elementType": "geometry", "stylers": [{ "color": "#000000" }] }
]
''';