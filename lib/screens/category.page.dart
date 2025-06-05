import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smarket/controllers/markets.controller.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;
  const CategoryPage({super.key, required this.categoryName});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  String _searchQuery = '';
  String _selectedMarket = 'Todos';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.categoryName,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _showFilterDialog();
            },
            icon: Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar produtos',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
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

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 50),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum produto encontrado',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _selectedMarket != 'Todos'
                              ? 'Filtros ativos: ${widget.categoryName} e $_selectedMarket'
                              : 'Categoria: ${widget.categoryName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductItem(products[index]);
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

    if (_selectedMarket != 'Todos') {
      query = query.where('mercado', isEqualTo: _selectedMarket);
    }
    if (_searchQuery.isNotEmpty) {
      query = query
          .where('nome', isGreaterThanOrEqualTo: _searchQuery)
          .where('nome', isLessThanOrEqualTo: '$_searchQuery\uf8ff');
    }
    return query.snapshots();
  }

  Widget _buildProductItem(DocumentSnapshot doc) {
    final product = doc.data() as Map<String, dynamic>;
    final isFavorited =
        (product['favoritadoPor'] as List?)?.contains(userId) ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          children: [Text('R\$ ${product['preco']}'), Text(product['mercado'])],
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : null,
          ),
          onPressed: () => _toggleFavorite(doc.id, isFavorited),
        ),
        onTap: () {
          // Navegar para detalhes do produto se necessário
        },
      ),
    );
  }

  Future<void> _toggleFavorite(
    String productId,
    bool isCurrentlyFavorited,
  ) async {
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('produtos')
        .doc(productId);

    if (isCurrentlyFavorited) {
      await docRef.update({
        'favoritadoPor': FieldValue.arrayRemove([userId]),
      });
    } else {
      await docRef.update({
        'favoritadoPor': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Future<void> _showFilterDialog() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final marketsController = MarketsController();
      await marketsController.findMarketsOSM();

      if (!mounted) return;
      Navigator.pop(context);

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) {
          String searchText = '';
          List<String> filteredMarkets = ['Todos']..addAll(
            marketsController.state.markets
                .map((m) => m['name'].toString())
                .toList(),
          );

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Filtrar por mercado'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Pesquisar mercado...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                            filteredMarkets = ['Todos']..addAll(
                              marketsController.state.markets
                                  .where(
                                    (market) => market['name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(value.toLowerCase()),
                                  )
                                  .map((m) => m['name'].toString())
                                  .toList(),
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child:
                            filteredMarkets.isEmpty
                                ? const Center(
                                  child: Text('Nenhum mercado encontrado'),
                                )
                                : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredMarkets.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(filteredMarkets[index]),
                                      onTap: () {
                                        _selectedMarket =
                                            filteredMarkets[index];
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _selectedMarket = 'Todos';
                      Navigator.pop(context);
                    },
                    child: const Text('Limpar filtro'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Erro'),
                content: Text(
                  'Não foi possível carregar os mercados: ${e.toString()}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }
}
