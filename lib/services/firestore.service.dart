import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference productsCollection = FirebaseFirestore.instance
      .collection('produtos');

  Future<void> addProduct({
    required String name,
    required String description,
    required String price,
    required String category,
    required String market,
  }) async {
    try {
      await productsCollection.add({
        'nome': name.trim(),
        'descricao': description.trim(),
        'preco': price.trim(),
        'categoria': category.toLowerCase().trim(),
        'mercado': market.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'favoritadoPor': [],
      });
    } catch (_) {
      throw Exception('Erro ao adicionar produto ao Firestore');
    }
  }
}
