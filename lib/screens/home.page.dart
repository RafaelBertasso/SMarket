import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smarket/components/navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                    Icon(Icons.notifications_none, size: 28),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '1',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 120),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Pesquisar Produtos',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Busque por categoria',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Ver tudo', style: TextStyle(color: Colors.blue)),
              ],
            ),
            SizedBox(height: 12),

            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryButton(context, 'Limpeza'),
                  _buildCategoryButton(context, 'Legumes'),
                  _buildCategoryButton(context, 'Bebidas'),
                  _buildCategoryButton(context, 'Pet'),
                ],
              ),
            ),
            SizedBox(height: 24),

            _buildPromoButton(context, screenWidth),
            SizedBox(height: 16),
            _buildPromoButton(context, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ElevatedButton(
        onPressed: () {
          NavBar.switchToTab(context, 3);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildPromoButton(BuildContext context, double screenWidth) {
    return SizedBox(
      width: screenWidth,
      height: 140,
      child: ElevatedButton(
        onPressed: () {
          NavBar.switchToTab(context, 3);
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
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
