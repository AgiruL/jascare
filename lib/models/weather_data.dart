import 'package:flutter/material.dart';

class WeatherTimelineItem {
  final String timeOffset;
  final String label;
  final int temp;
  final IconData icon;

  const WeatherTimelineItem({
    required this.timeOffset,
    required this.label,
    required this.temp,
    required this.icon,
  });
}

class WeatherConfig {
  final String headerLabel;
  final int mainTemp;
  final int humidity;
  final String alertMessage;
  final List<WeatherTimelineItem> timeline;

  const WeatherConfig({
    required this.headerLabel,
    required this.mainTemp,
    required this.humidity,
    required this.alertMessage,
    required this.timeline,
  });

  static WeatherConfig getConfig(String condition) {
    switch (condition) {
      case "windy":
        return const WeatherConfig(
          headerLabel: "Gale Winds",
          mainTemp: 28,
          humidity: 62,
          alertMessage: "💨 High winds detected — secure lightweight items and ride with care.",
          timeline: [
            WeatherTimelineItem(timeOffset: "-6h", label: "Sunny", temp: 32, icon: Icons.wb_sunny),
            WeatherTimelineItem(timeOffset: "-3h", label: "Clear", temp: 30, icon: Icons.wb_cloudy_outlined),
            WeatherTimelineItem(timeOffset: "Now", label: "Windy", temp: 28, icon: Icons.air),
            WeatherTimelineItem(timeOffset: "+3h", label: "Cloudy", temp: 26, icon: Icons.cloud),
            WeatherTimelineItem(timeOffset: "+6h", label: "Rain", temp: 24, icon: Icons.thunderstorm),
          ],
        );
      case "rain":
        return const WeatherConfig(
          headerLabel: "Moderate rain",
          mainTemp: 25,
          humidity: 89,
          alertMessage: "⚡ Rain detected — riders, get your coat/umbrella ready.",
          timeline: [
            WeatherTimelineItem(timeOffset: "-6h", label: "Cloudy", temp: 30, icon: Icons.cloud),
            WeatherTimelineItem(timeOffset: "-3h", label: "Light rain", temp: 27, icon: Icons.grain),
            WeatherTimelineItem(timeOffset: "Now", label: "Mod. Rain", temp: 25, icon: Icons.thunderstorm),
            WeatherTimelineItem(timeOffset: "+3h", label: "Overcast", temp: 26, icon: Icons.cloud_queue),
            WeatherTimelineItem(timeOffset: "+6h", label: "Clear", temp: 23, icon: Icons.dark_mode),
          ],
        );
      case "night":
        return const WeatherConfig(
          headerLabel: "Clear night",
          mainTemp: 23,
          humidity: 72,
          alertMessage: "🌙 Clear night — good visibility across campus fields.",
          timeline: [
            WeatherTimelineItem(timeOffset: "-6h", label: "Sunset", temp: 30, icon: Icons.wb_twilight),
            WeatherTimelineItem(timeOffset: "-3h", label: "Overcast", temp: 26, icon: Icons.cloud),
            WeatherTimelineItem(timeOffset: "Now", label: "Night", temp: 23, icon: Icons.nightlight_round),
            WeatherTimelineItem(timeOffset: "+3h", label: "Cool", temp: 22, icon: Icons.brightness_3),
            WeatherTimelineItem(timeOffset: "+6h", label: "Dawn", temp: 24, icon: Icons.wb_sunny_outlined),
          ],
        );
      case "sunny":
      default:
        return const WeatherConfig(
          headerLabel: "Bright sunshine",
          mainTemp: 34,
          humidity: 55,
          alertMessage: "☀️ Clear skies — safe riding conditions verified.",
          timeline: [
            WeatherTimelineItem(timeOffset: "-6h", label: "Clear", temp: 28, icon: Icons.wb_sunny_outlined),
            WeatherTimelineItem(timeOffset: "-3h", label: "Sunny", temp: 31, icon: Icons.wb_sunny),
            WeatherTimelineItem(timeOffset: "Now", label: "Sunshine", temp: 34, icon: Icons.wb_sunny),
            WeatherTimelineItem(timeOffset: "+3h", label: "Warm", temp: 32, icon: Icons.wb_sunny),
            WeatherTimelineItem(timeOffset: "+6h", label: "Sunset", temp: 27, icon: Icons.wb_twilight),
          ],
        );
    }
  }
}