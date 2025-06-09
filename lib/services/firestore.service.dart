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
      final nameLower = name.toLowerCase();
      await productsCollection.add({
        'nome': name.trim(),
        'nomeLower': nameLower.trim(),
        'descricao': description.trim(),
        'preco': price.trim(),
        'categoria': category.toLowerCase().trim(),
        'mercado': market.trim(),
        'dataAdicionado': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception('Erro ao adicionar produto ao Firestore');
    }
  }
  Future<QuerySnapshot> searchProducts(String query) async{
    final searchTerm = query.toLowerCase().trim();
    if (searchTerm.isEmpty) {
      return await productsCollection.limit(1).get();
    }
    return productsCollection
        .where('nomeLower', isGreaterThanOrEqualTo: searchTerm)
        .where('nomeLower', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .limit(10)
        .get();
  }
}
