import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarket/components/product.info.components.dart';
import 'package:smarket/controllers/product.info.controller.dart';
import 'package:smarket/models/product.info.model.dart';
import '../providers/favorites.provider.dart';

class ProductInfoPage extends StatelessWidget {
  ProductInfoPage({super.key, required this.productId});

  final String productId;
  final ProductController _productController = ProductController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<ProductModel>(
        future: _productController.fetchProduct(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
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
          final isFavorited = favoritesProvider.favoriteIds.contains(productId);

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
                        final isFavorited = favoritesProvider.favoriteIds
                            .contains(productId);
                        return IconButton(
                          icon: Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
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
                                color: Colors.deepOrange,
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
                            buildInfoChip(
                              icon: Icons.store_outlined,
                              label: product.market ?? 'Mercado',
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            buildInfoChip(
                              icon: Icons.category_outlined,
                              label: product.category ?? 'Categoria',
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ),

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
