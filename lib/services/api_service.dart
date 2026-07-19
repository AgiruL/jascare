
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
        data['title'] = (data['title'] != null && data['title'].toString().isNotEmpty)
            ? data['title']
            : data['incident'];
            
        data['status'] = data['isActive'] == true ? 'active' : 'solved';
        return data;
      }).toList();

      print("GET REPORTS STATUS: Success");
      print("GET REPORTS COUNT: ${reportsList.length}");
      return reportsList;
      
    // 👇 Make sure these closing brackets are included at the bottom:
    } catch (e) {
      print("Get reports API error: $e");
      return [];
    }
  }

      static Future<bool> submitReport({
      required String username,
      required String title,
      required String incident,
      required String description,
      required double latitude,
      required double longitude,
      String? imageUrl,
    }) async {
      try {
      await _db.collection('reports').add({
        "username": username,
        "title": title,
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

  // ===============================
  // MARK REPORT AS SOLVED IN CLOUD
  // ===============================
  static Future<bool> markReportAsSolved(String documentId) async {
    try {
      await _db.collection('reports').doc(documentId).update({
        'isActive': false,
      });
      print("REPORT STATUS: Document $documentId marked as solved in Firestore");
      return true;
    } catch (e) {
      print("Failed to update report status in Firestore: $e");
      return false;
    }
  }

  // ===============================
  // DELETE INCIDENT FROM CLOUD
  // ===============================
  static Future<bool> deleteReport(String documentId) async {
    try {
      await _db.collection('reports').doc(documentId).delete();
      print("REPORT STATUS: Document $documentId deleted from Firestore cleanly");
      return true;
    } catch (e) {
      print("Failed to delete report document from Firestore: $e");
      return false;
    }
  }

}