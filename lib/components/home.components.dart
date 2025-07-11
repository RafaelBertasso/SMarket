import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smarket/components/market.filter.dart';
import 'package:smarket/controllers/home.controller.dart';
import 'package:smarket/models/home.model.dart';
import '../screens/product.info.page.dart';

Widget buildHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/smarket-logo.png',
                width: 40,
                height: 40,
              ),
              Text(
                'SMARKT',
                style: GoogleFonts.daysOne(fontSize: 24, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget buildSearchField(
  BuildContext context,
  HomeController controller,
  TextEditingController searchController,
) {
  final searchController = TextEditingController();

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 248, 248, 248),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        const Icon(Icons.search, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: searchController,
            style: GoogleFonts.inter(),
            decoration: const InputDecoration(
              hintText: 'Pesquisar Produtos',
              border: InputBorder.none,
            ),
            onSubmitted: (value) async {
              if (value.trim().isEmpty) return;

              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) =>
                        const Center(child: CircularProgressIndicator()),
              );

              try {
                final result = await controller.searchProducts(value);

                Navigator.pop(context);

                if (result != null &&
                    result.isNotEmpty &&
                    result['category'] != null) {
                  Navigator.pushNamed(
                    context,
                    '/category',
                    arguments: {
                      'categoryName': _formatCategoryName(result['category']),
                      'highlightProduct': result['id'],
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Produto não encontrado'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao buscar produtos'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              searchController.clear();
            },
          ),
        ),
      ],
    ),
  );
}

String _formatCategoryName(String category) {
  return category[0].toUpperCase() + category.substring(1).toLowerCase();
}

Widget buildCategoriesSection(BuildContext context, HomeController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Busque por categoria',
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 15),
      SizedBox(
        height: 110,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children:
              controller
                  .getCategories()
                  .map((category) => _buildCategoryButton(context, category))
                  .toList(),
        ),
      ),
    ],
  );
}

Widget _buildCategoryButton(BuildContext context, Category category) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap:
                () => Navigator.pushNamed(
                  context,
                  category.route,
                  arguments: {'categoryName': category.label},
                ),
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              child: Icon(category.icon, size: 28, color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            category.label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget buildRecentProductsSection(
  double bottomSectionHeight,
  HomeController controller,
) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      height: 250,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(22, 0, 0, 0),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Novidades de Hoje',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Consumer<MarketFilter>(
            builder: (context, marketFilter, child) {
              return StreamBuilder<List<Product>>(
                stream: controller.getRecentProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildErrorWidget('Erro ao carregar produtos');
                  }

                  final products = snapshot.data ?? [];
                  final filteredProducts = controller.filterByMarket(
                    products,
                    marketFilter.selectedMarket,
                  );

                  if (filteredProducts.isEmpty) {
                    return _buildErrorWidget(
                      'Nenhum produto recente encontrado',
                    );
                  }

                  return SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return _buildRecentProductCard(
                          context,
                          filteredProducts[index],
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildErrorWidget(String message) {
  return SizedBox(
    height: 160,
    child: Center(child: Text(message, style: GoogleFonts.inter())),
  );
}

Widget _buildRecentProductCard(BuildContext context, Product product) {
  final diff = DateTime.now().difference(product.dataAdicionado);
  final tempoDecorrido =
      diff.inHours > 0 ? 'Há ${diff.inHours}h' : 'Há ${diff.inMinutes}min';

  return Container(
    width: 260,
    margin: const EdgeInsets.only(right: 16),
    child: Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      shadowColor: const Color.fromARGB(39, 0, 0, 0),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductInfoPage(productId: product.id),
              ),
            ),
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tempoDecorrido,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                product.mercado,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                product.mercadoEndereco,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Product name
                  Text(
                    product.nome,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Description
                  if (product.descricao != null &&
                      product.descricao!.isNotEmpty) ...[
                    Text(
                      product.descricao!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Price section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.green.shade100,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'R\$ ${product.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: GoogleFonts.inter(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.green.shade600,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
