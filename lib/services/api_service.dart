
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class ApiService {
static final FirebaseFirestore _db = FirebaseFirestore.instance;
  // ===============================
  // GET ALL LOCATIONS
  // ===============================
  static Future<List<dynamic>> getLocations() async {

    try {
      QuerySnapshot snapshot = await _db.collection('locations').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; 
        return data;
      }).toList();
    } catch (e) {
      debugPrint("Get locations Firestore error: $e");
      return [];
    }
  }

  static Future<List<dynamic>> getReports() async {
  try {
    QuerySnapshot snapshot = await _db.collection('reports').get();

    final List<dynamic> reportsList = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        // Map dynamic active status flag values cleanly for the local UI layers
        data['status'] = data['isActive'] == true ? 'active' : 'solved';
        return data;
      }).toList();

      print("GET REPORTS STATUS: Success");
      print("GET REPORTS COUNT: ${reportsList.length}");
      return reportsList;
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
      await _db.collection('reports').add({
        "username": username,
        "incident": incident,
        "description": description,
        "latitude": latitude,
        "longitude": longitude,
        "image_url": imageUrl,
        "isActive": true,
        "createdAt": FieldValue.serverTimestamp(),
      });

      print("REPORT STATUS: 201 Created (Saved to Firestore)");
      return true;
    } catch (e) {
      print("Report API error: $e");
      return false;
    }
  }

}