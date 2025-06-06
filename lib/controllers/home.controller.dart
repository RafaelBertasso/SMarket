import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smarket/models/home.model.dart';
import 'package:smarket/services/firestore.service.dart';

class HomeController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();

  Stream<List<Product>> getRecentProducts() {
    return _firestore
        .collection('produtos')
        .where(
          'dataAdicionado',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 1)),
          ),
        )
        .orderBy('dataAdicionado', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromDocument(doc)).toList(),
        );
  }

  List<Product> filterByMarket(List<Product> products, String market) {
    if (market == 'Todos') return products;
    return products.where((p) => p.mercado == market).toList();
  }

  List<Category> getCategories() {
    return [
      Category(
        icon: Icons.kebab_dining_rounded,
        label: 'Açougue',
        route: '/category',
      ),
      Category(
        icon: Icons.wine_bar_rounded,
        label: 'Bebidas',
        route: '/category',
      ),
      Category(
        icon: Icons.local_florist,
        label: 'Feirinha',
        route: '/category',
      ),
      Category(icon: Icons.clean_hands, label: 'Higiene', route: '/category'),
      Category(
        icon: Icons.cleaning_services,
        label: 'Limpeza',
        route: '/category',
      ),
      Category(
        icon: Icons.dinner_dining_rounded,
        label: 'Massas',
        route: '/category',
      ),
      Category(icon: Icons.pets, label: 'Pet', route: '/category'),
    ];
  }

  Future<Map<String, dynamic>?> searchProducts(String productName) async {
    try {
      final result = await _firestoreService.searchProducts(productName);
      if (result.docs.isNotEmpty) {
        final doc = result.docs.first;
        final data = doc.data() as Map<String, dynamic>;

        return {
          'id': doc.id,
          'nome': data['nome'],
          'categoria': data['categoria'],
          'data': data,
        };
      }
      return null;
    } catch (_) {
      throw Exception('Erro ao buscar produtos');
    }
  }
}
