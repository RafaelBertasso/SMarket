import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/favorites.provider.dart';

class ProductInfoPage extends StatelessWidget {
  const ProductInfoPage({super.key, required this.productId});

  final String productId;

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchProduct() {
    return FirebaseFirestore.instance.collection('produtos').doc(productId).get();
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

  String _formatDate(dynamic dateField) {
    if (dateField == null) return 'Data não informada';
    
    DateTime date;
    if (dateField is Timestamp) {
      date = dateField.toDate();
    } else if (dateField is String) {
      try {
        date = DateTime.parse(dateField);
      } catch (e) {
        return dateField;
      }
    } else {
      return dateField.toString();
    }
    
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _fetchProduct(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
              ),
            );
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.black),
              ),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Produto não encontrado',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!.data()!;
          final productId = this.productId;
          final favoritesProvider = Provider.of<FavoritesProvider>(context);
          final isFavorited = favoritesProvider.favoriteIds.contains(productId);

          return CustomScrollView(
            slivers: [
              // Modern App Bar with Product Image
              SliverAppBar(
                expandedHeight: 350.0,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Product Image
                      data['image_url'] != null
                          ? Image.network(
                              data['image_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                _getCategoryImage(data['categoria']),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              _getCategoryImage(data['categoria']),
                              fit: BoxFit.cover,
                            ),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Consumer<FavoritesProvider>(
                      builder: (context, favoritesProvider, _) {
                        final isFavorited = favoritesProvider.favoriteIds.contains(productId);
                        return IconButton(
                          icon: Icon(
                            isFavorited ? Icons.favorite : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            favoritesProvider.toggleFavorite(productId);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Product Information
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price Badge
                      Container(
                        margin: const EdgeInsets.only(top: 16, left: 24, right: 24),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                'PROMOÇÃO',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              data['preco'] != null
                                  ? 'R\$ ${double.parse(data['preco'].toString()).toStringAsFixed(2).replaceAll('.', ',')}'
                                  : 'R\$ 0,00',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Product Name
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        margin: const EdgeInsets.only(top: 16),
                        child: Text(
                          data['nome'] ?? 'Produto sem nome',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                      ),

                      // Market and Category Info
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        margin: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            _buildInfoChip(
                              icon: Icons.store_outlined,
                              label: data['mercado'] ?? 'Mercado',
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            _buildInfoChip(
                              icon: Icons.category_outlined,
                              label: data['categoria'] ?? 'Categoria',
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ),

                      // Description Section
                      if (data['descricao'] != null && data['descricao'].toString().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Descrição',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['descricao'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Additional Information
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informações Adicionais',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Data de Adição',
                              value: _formatDate(data['dataAdicionado']),
                            ),
                            if (data['validade'] != null) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                icon: Icons.schedule_outlined,
                                label: 'Válido até',
                                value: _formatDate(data['validade']),
                              ),
                            ],
                            if (data['desconto'] != null) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                icon: Icons.local_offer_outlined,
                                label: 'Desconto',
                                value: '${data['desconto']}%',
                              ),
                            ],
                            if (data['precoOriginal'] != null) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                icon: Icons.money_off_outlined,
                                label: 'Preço Original',
                                value: 'R\$ ${double.parse(data['precoOriginal'].toString()).toStringAsFixed(2).replaceAll('.', ',')}',
                              ),
                            ],
                          ],
                        ),
                      ),



                      // Bottom spacing
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}