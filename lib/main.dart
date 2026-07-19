import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // ✅ Imported your new login screen view
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  // ✅ 1. Ensures native bindings are set up
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ 2. Initializes the Firebase app link
  await Firebase.initializeApp();
  
  // 🔥 3. ADD THIS LINE RIGHT HERE TO BYPASS RECAPTCHA / SAFETYNET LOOPS FOR LOCAL TESTING
  await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
  
  runApp(const JasCareApp());
}

class JasCareApp extends StatefulWidget {
  const JasCareApp({super.key});

  @override
  State<JasCareApp> createState() => _JasCareAppState();
}

class _JasCareAppState extends State<JasCareApp> {
  String _currentWeather = "sunny"; 
  bool _isFullscreen = false;
  Timer? _weatherTicker;

  @override
  void initState() {
    super.initState();
    _determineSolidWeather();
    _weatherTicker = Timer.periodic(const Duration(seconds: 15), (_) {
      _determineSolidWeather();
    });
  }

  @override
  void dispose() {
    _weatherTicker?.cancel();
    super.dispose();
  }

  void _determineSolidWeather() {
    if (_currentWeather == "rain") return;
    final now = DateTime.now();
    final double timeAsDouble = now.hour + (now.minute / 60.0);

    String newCondition;
    if ((timeAsDouble >= 7.0 && timeAsDouble < 7.5) || (timeAsDouble >= 19.0 && timeAsDouble < 19.5)) {
      newCondition = "windy";
    } else if (timeAsDouble >= 7.5 && timeAsDouble < 19.0) {
      newCondition = "sunny";
    } else {
      newCondition = "night";
    }

    // ✅ ONLY trigger setState if the weather actually shifts! Saves huge CPU performance.
    if (_currentWeather != newCondition) {
      setState(() {
        _currentWeather = newCondition;
      });
    }
  }

  

  void _changeWeather(String weather) {
    setState(() => _currentWeather = weather);
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
  }

  ThemeData _buildFigmaTheme() {
    final bool isDark = _currentWeather != "sunny";
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFFD97706),
      scaffoldBackgroundColor: isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF7F6F0),
      cardColor: isDark ? const Color(0xFF161625) : Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JasCare',
      debugShowCheckedModeBanner: false,
      theme: _buildFigmaTheme(),
      // ✅ Enforces Login Screen first while passing down your persistent weather states!
      home: Builder(
        builder: (context) => LoginScreen(
          currentWeather: _currentWeather,
          isFullscreen: _isFullscreen,
          onWeatherChanged: _changeWeather,
          onToggleFullscreen: _toggleFullscreen,
        ),
      ),
    );
  }
}