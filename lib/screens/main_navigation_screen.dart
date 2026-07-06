import 'package:flutter/material.dart';
import 'campus_map_screen.dart';
import 'incidents_screen.dart';
import 'about_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CustomIncident {
  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String category; 
  final String? imagePath; 
  bool isActive;           

  CustomIncident({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.imagePath,
    this.isActive = true,
  });

  // Convert object to a Map for JSON encoding
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'imagePath': imagePath,
      'isActive': isActive,
    };
  }
}

class MainNavigationScreen extends StatefulWidget {
  final String currentWeather;
  final bool isFullscreen;
  final ValueChanged<String> onWeatherChanged;
  final VoidCallback onToggleFullscreen;

  const MainNavigationScreen({
    super.key,
    required this.currentWeather,
    required this.isFullscreen,
    required this.onWeatherChanged,
    required this.onToggleFullscreen,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<CustomIncident> _globalIncidents = [
    CustomIncident(
      id: 'f1',
      title: "Suspicious Activity",
      description: "Near Block A layout lines",
      latitude: 2.2145,
      longitude: 102.4535,
      category: "Crime",
      isActive: true,
    ),
    CustomIncident(
      id: 'f2',
      title: "Broken Corridor Spotlight",
      description: "Dim walkway infrastructure",
      latitude: 2.2110,
      longitude: 102.4520,
      category: "Facility",
      isActive: false, 
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPersistedIncidents(); // Load the data the moment this screen turns on!
  }

  // 💾 NEW CENTRAL SAVE FUNCTION: Call this whenever the array updates
  Future<void> _saveAllIncidentsToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> jsonList = _globalIncidents
          .map((incident) => jsonEncode(incident.toMap()))
          .toList();
      await prefs.setStringList('local_incidents', jsonList);
    } catch (e) {
      debugPrint("Failed to save data sync update: $e");
    }
  }

  // UPDATED: Now saves to storage after adding
  void _addIncident(CustomIncident incident) {
    setState(() {
      _globalIncidents.add(incident);
    });
    _saveAllIncidentsToDisk(); // Update local disk file!
  }

  // UPDATED: Now saves to storage after updating to solved
  void _markAsSolved(String id) {
    setState(() {
      final incident = _globalIncidents.firstWhere((item) => item.id == id);
      incident.isActive = false;
    });
    _saveAllIncidentsToDisk(); // Update local disk file!
  }

  // UPDATED: Now saves to storage after deleting completely
  void _permanentlyDelete(String id) {
    setState(() {
      _globalIncidents.removeWhere((item) => item.id == id);
    });
    _saveAllIncidentsToDisk(); // Update local disk file!
  }

  Future<void> _loadPersistedIncidents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> storedList = prefs.getStringList('local_incidents') ?? [];
      
      if (storedList.isNotEmpty) {
        List<CustomIncident> loadedIncidents = [];
        
        for (String jsonStr in storedList) {
          Map<String, dynamic> item = jsonDecode(jsonStr);
          
          // Avoid duplicating initial hardcoded items ('f1', 'f2') if they are read from disk
          if (_globalIncidents.any((element) => element.id == item['id'])) {
            continue;
          }

          loadedIncidents.add(
            CustomIncident(
              id: item['id'],
              title: item['title'],
              description: item['description'],
              latitude: item['latitude'],
              longitude: item['longitude'],
              category: item['category'],
              imagePath: item['imagePath'],
              isActive: item['isActive'] ?? true,
            ),
          );
        }
        
        setState(() {
          _globalIncidents.addAll(loadedIncidents); 
        });
      }
    } catch (e) {
      debugPrint("Error loading persisted data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.currentWeather == "rain" || widget.currentWeather == "night";
    
    final List<Widget> screens = [
      CampusMapScreen(
        currentWeather: widget.currentWeather,
        isFullscreen: widget.isFullscreen,
        onWeatherChanged: widget.onWeatherChanged,
        onToggleFullscreen: widget.onToggleFullscreen,
        incidentList: _globalIncidents,
        onAddIncident: _addIncident,
      ),
      IncidentsScreen(
        incidentList: _globalIncidents,
        onSolve: _markAsSolved,
        onDelete: _permanentlyDelete,
        isDark: isDark,
      ),
      const AboutScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: widget.isFullscreen 
          ? null 
          : NavigationBar(
              selectedIndex: _currentIndex,
              backgroundColor: isDark ? const Color(0xFF161625) : Colors.white,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
                NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'Incidents'),
                NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'About'),
              ],
            ),
    );
  }
}