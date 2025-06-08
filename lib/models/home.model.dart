import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Product {
  final String id;
  final String nome;
  final String? descricao;
  final double preco;
  final String mercado;
  final String mercadoEndereco;
  final String categoria;
  final DateTime dataAdicionado;

  Product({
    required this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    required this.mercado,
    required this.mercadoEndereco,
    required this.categoria,
    required this.dataAdicionado,
  });

  factory Product.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      nome: data['nome'] ?? 'Sem nome',
      descricao: data['descricao'],
      preco: double.tryParse(data['preco'].toString()) ?? 0.0,
      mercado: data['mercado'] ?? 'Mercado não informado',
      mercadoEndereco: data['mercadoEndereco'] ?? 'Endereço não informado',
      categoria: data['categoria'] ?? 'outros',
      dataAdicionado: (data['dataAdicionado'] as Timestamp).toDate(),
    );
  }
}

class Category {
  final IconData icon;
  final String label;
  final String route;

  Category({required this.icon, required this.label, required this.route});
}
