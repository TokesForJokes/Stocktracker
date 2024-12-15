import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add stock to user's watchlist
  Future<void> addToWatchlist(String userId, String stockSymbol) async {
    await _db.collection('watchlists').doc(userId).set({
      'stocks': FieldValue.arrayUnion([stockSymbol])
    }, SetOptions(merge: true));
  }

  // Remove stock from user's watchlist
  Future<void> removeFromWatchlist(String userId, String stockSymbol) async {
    await _db.collection('watchlists').doc(userId).update({
      'stocks': FieldValue.arrayRemove([stockSymbol])
    });
  }

  // Stream watchlist updates in real-time
  Stream<List<String>> getWatchlist(String userId) {
    return _db.collection('watchlists').doc(userId).snapshots().map((snapshot) {
      return List<String>.from(snapshot.data()?['stocks'] ?? []);
    });
  }

  // Fetch user data based on UID
  Future<Map<String, dynamic>> getUserData(String uid) async {
    final snapshot = await _db.collection('users').doc(uid).get();
    if (snapshot.exists) {
      return snapshot.data() ?? {};
    } else {
      throw Exception("User data not found");
    }
  }
}
