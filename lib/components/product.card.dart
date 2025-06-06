import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/favorites.provider.dart';
import '../screens/product.info.page.dart';

class ProductCard extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final FavoritesProvider favoritesProvider;

  const ProductCard({
    super.key,
    required this.doc,
    required this.favoritesProvider,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data()!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductInfoPage(productId: doc.id),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildProductImage(data),
                const SizedBox(width: 16),
                Expanded(child: _buildProductInfo(data)),
                _buildPriceAndFavorite(data, doc.id, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Map<String, dynamic> data) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: data['image_url'] != null
            ? Image.network(
                data['image_url'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  _getCategoryImage(data['categoria']),
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                _getCategoryImage(data['categoria']),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildProductInfo(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data['nome'] ?? 'Produto sem nome',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (data['mercado'] != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              data['mercado'],
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 8),
        if (data['descricao'] != null)
          Text(
            data['descricao'],
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildPriceAndFavorite(
    Map<String, dynamic> data,
    String productId,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          data['preco'] != null
              ? 'R\$ ${double.parse(data['preco'].toString()).toStringAsFixed(2).replaceAll('.', ',')}'
              : 'R\$ 0,00',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 150),
          child: IconButton(
            onPressed: () {
              favoritesProvider.toggleFavorite(productId);
            },
            icon: const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ),
      ],
    );
  }

  String _getCategoryImage(String? category) {
    if (category == null) return 'assets/images/default.png';
    switch (category.toLowerCase()) {
      case 'açougue':
      case 'acougue':
        return 'assets/images/acougue.png';
      case 'bebidas':
        return 'assets/images/bebidas.png';
      case 'feirinha':
        return 'assets/images/feirinha.png';
      case 'higiene':
        return 'assets/images/higiene.png';
      case 'limpeza':
        return 'assets/images/limpeza.png';
      case 'massas':
        return 'assets/images/massas.png';
      case 'pet':
        return 'assets/images/pet.png';
      default:
        return 'assets/images/default.png';
    }
  }
}
