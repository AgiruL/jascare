import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // 🔑 ALLOCATION CREDENTIALS MATCHED TO YOUR DASHBOARD SCREENSHOTS
  static const String _cloudName = "dx4dtwvz";
  static const String _uploadPreset = "jascare_preset";
  static const String _apiKey = "236112912291891"; // 🏢 From your API Keys dashboard tab

  /// Sends a local file path upstream to Cloudinary CDN servers.
  static Future<String?> uploadIncidentImage(String localFilePath) async {
    try {
      // 🌐 Absolute Explicit Upload URL mapping layout
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      
      var request = http.MultipartRequest('POST', url);
      
      // 📝 Injected parameter definitions clearing out the validation blocks
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['api_key'] = _apiKey; 

      request.files.add(await http.MultipartFile.fromPath('file', localFilePath));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        var parsedJson = jsonDecode(responseData);
        return parsedJson['secure_url'] as String?;
      } else {
        // Keeps the diagnostic loop tracking cleanly in your terminal windows
        debugPrint("Cloudinary upload failed: ${response.statusCode} $responseData");
      }
    } catch (e) {
      debugPrint("Cloudinary service network infrastructure error: $e");
    }
    return null;
  }
}