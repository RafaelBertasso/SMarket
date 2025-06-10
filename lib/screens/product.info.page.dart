import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarket/components/product.info.components.dart';
import 'package:smarket/controllers/product.info.controller.dart';
import 'package:smarket/models/product.info.model.dart';
import '../providers/favorites.provider.dart';

class ProductInfoPage extends StatefulWidget {
  ProductInfoPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductInfoPage> createState() => _ProductInfoPageState();
}

class _ProductInfoPageState extends State<ProductInfoPage> {
  final ProductController _productController = ProductController();
  bool _showThankYou = false;

  Future<void> _handlePromotionResponse(
    bool stillInPromotion,
    ProductModel product,
  ) async {
    if (stillInPromotion) {
      setState(() {
        _showThankYou = true;
      });
    } else {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Confirmar remoção'),
              content: const Text(
                'Tem certeza que deseja remover este produto da promoção?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 201, 13, 0),
                  ),
                  child: const Text('Remover'),
                ),
              ],
            ),
      );

      if (shouldDelete == true) {
        try {
          await _productController.deleteProduct(widget.productId);
          if (mounted) {
            Navigator.of(context).pop();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao remover produto: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Widget _buildPromotionQuestion(ProductModel product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O produto ainda está em promoção?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (_showThankYou)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      'Obrigado pela confirmação!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handlePromotionResponse(true, product),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'Sim',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handlePromotionResponse(false, product),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text(
                      'Não',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<ProductModel>(
        future: _productController.fetchProduct(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 34, 111, 255),
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
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
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
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

          final product = snapshot.data!;
          final favoritesProvider = Provider.of<FavoritesProvider>(context);
          final isFavorited = favoritesProvider.favoriteIds.contains(
            widget.productId,
          );

          return CustomScrollView(
            slivers: [
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
                      product.imageUrl != null
                          ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Image.asset(
                                  _productController.getCategoryImage(
                                    product.category,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                          )
                          : Image.asset(
                            _productController.getCategoryImage(
                              product.category,
                            ),
                            fit: BoxFit.cover,
                          ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color.fromARGB(87, 0, 0, 0),
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
                      color: const Color.fromARGB(90, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Consumer<FavoritesProvider>(
                      builder: (context, favoritesProvider, _) {
                        final isFavorited = favoritesProvider.favoriteIds
                            .contains(widget.productId);
                        return IconButton(
                          icon: Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            favoritesProvider.toggleFavorite(widget.productId);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

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
                      Container(
                        margin: const EdgeInsets.only(
                          top: 16,
                          left: 24,
                          right: 24,
                        ),
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
                              product.price != null
                                  ? 'R\$ ${product.price!.toStringAsFixed(2).replaceAll('.', ',')}'
                                  : 'R\$ 0,00',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 29, 227, 39),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        margin: const EdgeInsets.only(top: 16),
                        child: Text(
                          product.name ?? 'Produto sem nome',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        margin: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                _buildInfoChip(
                                  icon: Icons.store_outlined,
                                  label: product.market ?? 'Mercado',
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            _buildInfoChip(
                              icon: Icons.category_outlined,
                              label: product.category ?? 'Categoria',
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ),

                      _buildPromotionQuestion(product),

                      if (product.description != null &&
                          product.description!.isNotEmpty)
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
                                product.description!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

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
                            buildInfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Data de Adição',
                              value: _productController.formatDate(
                                product.addedDate,
                              ),
                            ),
                            if (product.expirationDate != null) ...[
                              const SizedBox(height: 12),
                              buildInfoRow(
                                icon: Icons.schedule_outlined,
                                label: 'Válido até',
                                value: _productController.formatDate(
                                  product.expirationDate,
                                ),
                              ),
                            ],
                            if (product.discount != null) ...[
                              const SizedBox(height: 12),
                              buildInfoRow(
                                icon: Icons.local_offer_outlined,
                                label: 'Desconto',
                                value: '${product.discount}%',
                              ),
                            ],
                            if (product.originalPrice != null) ...[
                              const SizedBox(height: 12),
                              buildInfoRow(
                                icon: Icons.money_off_outlined,
                                label: 'Preço Original',
                                value:
                                    'R\$ ${product.originalPrice!.toStringAsFixed(2).replaceAll('.', ',')}',
                              ),
                            ],
                          ],
                        ),
                      ),
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
}
