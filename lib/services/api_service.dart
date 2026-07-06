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

}