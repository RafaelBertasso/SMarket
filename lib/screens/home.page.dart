import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smarket/components/market.filter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSectionHeight = screenHeight * 0.35;
    return ChangeNotifierProvider(
      create: (_) => MarketFilter(),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(211, 233, 248, 1),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 25,
                right: 30,
                top: 25,
                bottom: bottomSectionHeight + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                                style: GoogleFonts.daysOne(
                                  fontSize: 24,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Container(
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
                            style: GoogleFonts.inter(),
                            decoration: const InputDecoration(
                              hintText: 'Pesquisar Produtos',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Busque por categoria',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      children: [
                        _buildCategoryButton(
                          context,
                          Icons.kebab_dining_rounded,
                          'Açougue',
                          '/favorites',
                        ),
                        _buildCategoryButton(
                          context,
                          Icons.wine_bar_rounded,
                          'Bebidas',
                          '/favorites',
                        ),
                        _buildCategoryButton(
                          context,
                          Icons.local_florist,
                          'Feirinha',
                          '/favorites',
                        ),
                        _buildCategoryButton(
                          context,
                          Icons.clean_hands,
                          'Higiene',
                          '/favorites',
                        ),
                        _buildCategoryButton(
                          context,
                          Icons.cleaning_services,
                          'Limpeza',
                          '/favorites',
                        ),
                        _buildCategoryButton(
                          context,
                          Icons.dinner_dining_rounded,
                          'Massas',
                          '/favorites',
                        ),
                        _buildCategoryButton(
                          context,
                          Icons.pets,
                          'Pet',
                          '/favorites',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
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
                        return StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('produtos')
                                  .where(
                                    'dataAdicionado',
                                    isGreaterThanOrEqualTo: Timestamp.fromDate(
                                      DateTime.now().subtract(
                                        const Duration(days: 1),
                                      ),
                                    ),
                                  )
                                  .orderBy('dataAdicionado', descending: true)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(
                                height: 160,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return SizedBox(
                                height: 160,
                                child: Center(
                                  child: Text(
                                    'Erro ao carregar produtos',
                                    style: GoogleFonts.inter(),
                                  ),
                                ),
                              );
                            }

                            final produtos = snapshot.data?.docs ?? [];
                            final filteredProdutos =
                                produtos.where((produto) {
                                  if (marketFilter.selectedMarket == 'Todos') {
                                    return true;
                                  }
                                  return produto['mercado'] ==
                                      marketFilter.selectedMarket;
                                }).toList();

                            if (filteredProdutos.isEmpty) {
                              return SizedBox(
                                height: 160,
                                child: Center(
                                  child: Text(
                                    'Nenhum produto recente encontrado',
                                    style: GoogleFonts.inter(),
                                  ),
                                ),
                              );
                            }

                            return SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: filteredProdutos.length,
                                itemBuilder: (context, index) {
                                  final produto = filteredProdutos[index];
                                  return _buildProdutoCard(produto);
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
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
                    '/category',
                    arguments: {'categoryName': label},
                  ),
              child: Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                child: Icon(icon, size: 28, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              label,
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

  Widget _buildProdutoCard(DocumentSnapshot produto) {
    final dataAdicionado = produto['dataAdicionado'] as Timestamp;
    final addDate = dataAdicionado.toDate();
    final now = DateTime.now();
    final diff = now.difference(addDate);

    String tempoDecorrido;
    if (diff.inHours > 0) {
      tempoDecorrido =
          'Adicionado há ${diff.inHours}h e ${diff.inMinutes.remainder(60)}min';
    } else {
      tempoDecorrido = 'Adicionado há ${diff.inMinutes}min';
    }

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto['nome'] ?? 'Produto sem nome',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (produto['descricao'] != null)
                  Text(
                    produto['descricao'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'R\$ ${produto['preco']}',
                      style: GoogleFonts.inter(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      produto['mercado'] ?? 'Mercado não informado',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tempoDecorrido,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
