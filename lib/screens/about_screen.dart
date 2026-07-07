import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart'; // Ensure access to CustomIncident definitions if mapped there

class AboutScreen extends StatelessWidget {
  // ✅ 1. Accept the live master dataset matrix from the navigation shell parent
  final List<CustomIncident> incidentList;

  const AboutScreen({
    super.key,
    required this.incidentList,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    // ✅ 2. Compute dynamic operational metrics directly from active data tracks
    final int activeCount = incidentList.where((e) => e.isActive).length;
    final int resolvedCount = incidentList.where((e) => !e.isActive).length;
    
    // Tracks categories based on the categorical type indicators within active state
    final int crimeCount = incidentList.where((e) => e.category == "Crime" && e.isActive).length;
    final int facilityCount = incidentList.where((e) => e.category != "Crime" && e.isActive).length;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B2A4A), Color(0xFF0F1524)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // 🎓 Student Profile Header Card
                const SizedBox(height: 10),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0x22FFFFFF),
                  child: Icon(Icons.school, size: 40, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                const Text("Amirul Haziq", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                const Text("amirul@student.uitm.edu.my", style: TextStyle(fontSize: 14, color: Colors.white60)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.withAlpha(40), borderRadius: BorderRadius.circular(20)),
                      child: const Text("STUDENT", style: TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(20)),
                      child: const Text("CDCS2516A - Group C", style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text("Faculty of Computer Science & Mathematics", style: TextStyle(fontSize: 12, color: Colors.white38)),
                
                const SizedBox(height: 24),
                // 🚪 Sign Out Command Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    await authService.signOut();
                    if (!context.mounted) return;
                    
                    // Forces navigation context layout back to the parameter-bound login page
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(
                          currentWeather: "sunny",
                          isFullscreen: false,
                            onWeatherChanged: (String _){}, // provide safe no-op callback
                            onToggleFullscreen: (){},
                        ),
                      ),
                      (route) => false,
                    );
                  },
                ),

                const SizedBox(height: 32),
                // 📊 Numeric Stats Grid System Layout (Now fully dynamic!)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard("$activeCount", "Active", Colors.orange),
                    _buildStatCard("$crimeCount", "Crimes", Colors.red),
                    _buildStatCard("$facilityCount", "Facility", Colors.amber),
                    _buildStatCard("$resolvedCount", "Resolved", Colors.green),
                  ],
                ),

                const SizedBox(height: 32),
                // 🌐 Ecosystem Integration Architecture Listing Row
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("4-CLOUD API ECOSYSTEM", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 12),
                _buildEcosystemTile(Icons.map_outlined, "Google Maps SDK", "GPS → Campus tiles + hub geocoding"),
                _buildEcosystemTile(Icons.cloud_queue_outlined, "OpenWeather API", "Live weather metrics → UI alerts"),
                _buildEcosystemTile(Icons.local_fire_department_outlined, "Firebase Firestore", "Real-time incident pin sync"),
                _buildEcosystemTile(Icons.cloud_upload_outlined, "Cloudinary CDN", "Unsigned asset delivery infrastructure"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String count, String label, Color indicatorColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161C2A),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: indicatorColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildEcosystemTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF161C2A), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6366F1), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }
}