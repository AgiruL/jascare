import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';

void main() {
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
    final now = DateTime.now();
    final double timeAsDouble = now.hour + (now.minute / 60.0);

    setState(() {
      if ((timeAsDouble >= 7.0 && timeAsDouble < 7.5) || (timeAsDouble >= 19.0 && timeAsDouble < 19.5)) {
        _currentWeather = "windy";
      } else if (timeAsDouble >= 7.5 && timeAsDouble < 19.0) {
        _currentWeather = "sunny";
      } else {
        _currentWeather = "night";
      }
    });
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
      home: MainNavigationScreen(
        currentWeather: _currentWeather,
        isFullscreen: _isFullscreen,
        onWeatherChanged: _changeWeather,
        onToggleFullscreen: _toggleFullscreen,
      ),
    );
  }
}