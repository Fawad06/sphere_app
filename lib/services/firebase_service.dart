import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final bannersCollection =
      FirebaseFirestore.instance.collection("banners");

  Future<String?> getRandomQuoteImageUrl() async {
    try {
      final snapshot = await bannersCollection.get();
      final allDocsData = snapshot.docs.map((e) => e.data()).toList();
      if (allDocsData.isNotEmpty) {
        final randomIndex = Random().nextInt(allDocsData.length);
        return allDocsData.elementAt(randomIndex)["imageUrl"] ?? "abc.com";
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("\n\nFirebase error: ${e.toString()}\n\n");
      }
    }
    return null;
  }

  Future<void> authenticate() async {
    try {
      if (kDebugMode) {
        print('\n\nSigning in to Firebase\n\n');
      }
      final userCred = await FirebaseAuth.instance.signInAnonymously();
      if (kDebugMode) {
        print('\n\nFirebase Auth Result: ${userCred.toString()}\n\n');
      }
    } catch (e) {
      if (kDebugMode) {
        print('\n\nFirebase Error: ${e.toString()}\n\n');
      }
    }
  }
}
