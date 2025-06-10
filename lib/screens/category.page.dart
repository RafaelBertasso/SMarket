import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:smarket/providers/favorites.provider.dart';
import 'package:smarket/screens/product.info.page.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;
  const CategoryPage({super.key, required this.categoryName});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  String searchQuery = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? highlightProductId = routeArgs?['highlightProduct'];
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.categoryName,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildProductStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 50,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar produtos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          snapshot.error.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductItem(
                      products[index],
                      highlightProductId: highlightProductId,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _buildProductStream() {
    final formattedCategory = widget.categoryName.toLowerCase();
    Query query = FirebaseFirestore.instance
        .collection('produtos')
        .where('categoria', isEqualTo: formattedCategory)
        .orderBy('dataAdicionado', descending: true);

    if (searchQuery.isNotEmpty) {
      query = query
          .where('nome', isGreaterThanOrEqualTo: searchQuery)
          .where('nome', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }
    return query.snapshots();
  }

  Widget _buildProductItem(DocumentSnapshot doc, {String? highlightProductId}) {
    final product = doc.data() as Map<String, dynamic>;
    final isHighlighted = doc.id == highlightProductId;

    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.yellow[100] : null,
        borderRadius: BorderRadius.circular(8),
        border:
            isHighlighted ? Border.all(color: Colors.orange, width: 2) : null,
        boxShadow:
            isHighlighted
                ? [
                  BoxShadow(
                    color: Color.fromARGB(74, 255, 153, 0),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
                : null,
      ),

      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              product['imagemUrl'] != null
                  ? NetworkImage(product['imagemUrl'])
                  : null,
          child:
              product['imagemUrl'] == null
                  ? const Icon(Icons.shopping_basket)
                  : null,
        ),
        title: Text(product['nome']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('R\$ ${product['preco']}'), Text('${product['mercado']} - ${product['mercadoEndereco']}')],
        ),
        trailing: Consumer<FavoritesProvider>(
          builder: (context, favoritesProvider, _) {
            final isFavorited = favoritesProvider.favoriteIds.contains(doc.id);
            return IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red : null,
              ),
              onPressed: () {
                favoritesProvider.toggleFavorite(doc.id);
              },
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductInfoPage(productId: doc.id),
            ),
          );
        },
      ),
    );
  }
}
