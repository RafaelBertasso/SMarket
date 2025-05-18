import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(211, 233, 248, 1),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(25, 24, 25, 200),
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
                    Stack(
                      children: [
                        const Icon(Icons.notifications_none, size: 28),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Campo de busca
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

                // Título
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
                const SizedBox(height: 12),

                // Categorias
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryButton(
                        context,
                        Icons.cleaning_services_rounded,
                        'Limpeza',
                        '/favorites',
                      ),
                      _buildCategoryButton(
                        context,
                        Icons.local_florist,
                        'Legumes',
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
                        Icons.pets_rounded,
                        'Pet',
                        '/favorites',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Container branco fixo no rodapé
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPromoButton(context, screenWidth),
                  const SizedBox(height: 16),
                  _buildPromoButton(context, screenWidth),
                ],
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, route);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              minimumSize: const Size(70, 70),
              padding: EdgeInsets.zero,
            ),
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPromoButton(BuildContext context, double screenWidth) {
    return SizedBox(
      width: screenWidth,
      height: 150,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/favorites');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/promo.png',
            width: screenWidth,
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
