import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smarket/screens/product.info.page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/main'); // Navigate back to HomePage
          },
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: const Color.fromARGB(255, 207, 202, 202),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  style: GoogleFonts.inter(),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar Produtos',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: ListView.builder(
        itemCount: 10, // Example: 10 products
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductInfoPage(productId: index),
                ),
              );
            },
            child: Container(
              height: 100,
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(105, 158, 158, 158),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Product ${index + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
