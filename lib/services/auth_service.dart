import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 📝 REGISTER ACCOUNT + PERSIST STUDENT METADATA
  Future<User?> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
    String studentId = "2021234567", // Default placeholder for profile row layout
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create user document inside Firestore collection matrix
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fullName': fullName.trim(),
          'email': email.trim(),
          'studentId': studentId,
          'faculty': 'Faculty of Computer Science & Mathematics',
          'role': 'STUDENT',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      debugPrint("Firebase Registration Pipeline Exception: $e");
      return null;
    }
  }

  // 🔑 AUTHENTICATE EXISTING USER
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } catch (e) {
      debugPrint("Firebase Login Pipeline Exception: $e");
      return null;
    }
  }

  // 🚪 TERMINATE SESSION SYSTEM LAYER
  Future<void> signOut() async {
    await _auth.signOut();
  }
}