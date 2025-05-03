import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPrefService {
  final _db = FirebaseFirestore.instance;

  Future<void> savePreferences({required String theme, required String language}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('preferences').doc(uid).set({
      'theme': theme,
      'language': language,
    });
  }

  Future<Map<String, dynamic>?> loadPreferences() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('preferences').doc(uid).get();
    return doc.data();
  }
}
