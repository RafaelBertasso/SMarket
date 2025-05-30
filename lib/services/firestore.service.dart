import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('produtos');

  Future<void> addProduct({
    required String name,
    required String description,
    required String price,
  }) async {
    await productsCollection.add({
      'nome': name,
      'descricao': description,
      'preco': price,
    });
  }
}
