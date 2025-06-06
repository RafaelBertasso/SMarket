import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String? name;
  final String? category;
  final String? market;
  final String? description;
  final String? imageUrl;
  final double? price;
  final double? originalPrice;
  final int? discount;
  final dynamic addedDate;
  final dynamic expirationDate;

  ProductModel({
    required this.id,
    this.name,
    this.category,
    this.market,
    this.description,
    this.imageUrl,
    this.price,
    this.originalPrice,
    this.discount,
    this.addedDate,
    this.expirationDate,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel(
      id: doc.id,
      name: data['nome'],
      category: data['categoria'],
      market: data['mercado'],
      description: data['descricao'],
      imageUrl: data['image_url'],
      price:
          data['preco'] != null ? double.parse(data['preco'].toString()) : null,
      originalPrice:
          data['precoOriginal'] != null
              ? double.parse(data['precoOriginal'].toString())
              : null,
      discount: data['desconto'],
      addedDate: data['dataAdicionado'],
      expirationDate: data['validade'],
    );
  }
}
