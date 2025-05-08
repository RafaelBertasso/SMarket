import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/main');
          },
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
        ),
        title: Text(
          'Encontre mercados próximos',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/images/map_bg.jpg', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.black26),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Pesquisar...',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black26,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
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
