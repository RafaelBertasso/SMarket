import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Set<String> _favoriteIds = {};
  StreamSubscription? _subscription;
  StreamSubscription<User?>? _authSubscription;

  FavoritesProvider() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      _listenToFavorites();
    });
    _listenToFavorites();
  }

  String? get _userId => _auth.currentUser?.uid;

  Set<String> get favoriteIds => _favoriteIds;

  void _listenToFavorites() {
    _subscription?.cancel();
    final userId = _userId;
    if (userId == null) {
      _favoriteIds = {};
      notifyListeners();
      return;
    }
    _subscription = _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .listen((snapshot) {
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toSet();
      notifyListeners();
    });
  }

  Future<void> toggleFavorite(String productId) async {
    final userId = _userId;
    if (userId == null) return;
    final favDoc = _db.collection('users').doc(userId).collection('favorites').doc(productId);
    if (_favoriteIds.contains(productId)) {
      await favDoc.delete();
    } else {
      await favDoc.set({'createdAt': FieldValue.serverTimestamp()});
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    _listenToFavorites();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
