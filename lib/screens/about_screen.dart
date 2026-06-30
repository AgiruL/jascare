import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Center(
              child: Icon(Icons.shield_outlined, color: Color(0xFF6366F1), size: 64),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text("JasCare", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            const Center(
              child: Text("SMART SAFE CAMPUS", style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            Text("4-CLOUD API ECOSYSTEM", style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _apiCard("Google Maps SDK", "Hardware GPS Alignment", isDark),
            _apiCard("OpenWeather API", "Live Climate Metrics Updates", isDark),
            _apiCard("Firebase Firestore", "Real-Time Incident Synchronization", isDark),
            _apiCard("Cloudinary CDN", "Secure Infrastructure Media Hosting", isDark),
          ],
        ),
      ),
    );
  }

  Widget _apiCard(String title, String desc, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF161625) : Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        leading: const Icon(Icons.cloud_done_outlined, color: Colors.blueAccent),
      ),
    );
  }
}