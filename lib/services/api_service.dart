import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {

  // ===============================
  // GET ALL LOCATIONS
  // ===============================
  static Future<List<dynamic>> getLocations() async {

    final response = await http.get(
      Uri.parse("${AppConfig.baseUrl}/locations"),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];

  }

  static Future<List<dynamic>> getReports() async {
  try {
    final response = await http.get(
      Uri.parse("${AppConfig.baseUrl}/reports"),
      headers: {
        "Accept": "application/json",
      },
    );

    print("GET REPORTS STATUS: ${response.statusCode}");
    print("GET REPORTS BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  } catch (e) {
    print("Get reports API error: $e");
    return [];
  }
}

      static Future<bool> submitReport({
      required String username,
      required String incident,
      required String description,
      required double latitude,
      required double longitude,
      String? imageUrl,
    }) async {
      try {
        final response = await http.post(
          Uri.parse("${AppConfig.baseUrl}/reports"),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "username": username,
            "incident": incident,
            "description": description,
            "latitude": latitude,
            "longitude": longitude,
            "image_url": imageUrl,
          }),
        );

        print("REPORT STATUS: ${response.statusCode}");
        print("REPORT BODY: ${response.body}");

        return response.statusCode == 201;
      } catch (e) {
        print("Report API error: $e");
        return false;
      }
    }

}