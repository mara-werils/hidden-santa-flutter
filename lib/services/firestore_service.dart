import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> saveUserProfile({
    required String theme,
    required String language,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'preferences': {
        'theme': theme,
        'language': language,
      },
    }, SetOptions(merge: true));
  }

  Future<void> saveHistory(List<String> pairs) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add({
      'timestamp': FieldValue.serverTimestamp(),
      'pairs': pairs,
    });
  }

  Future<void> saveHistorySession(Map<String, dynamic> session) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .add({
      'timestamp': FieldValue.serverTimestamp(),
      'pairs': session['pairs'] ?? [],
    });
  }

  Future<List<Map<String, dynamic>>> loadHistorySessions() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
