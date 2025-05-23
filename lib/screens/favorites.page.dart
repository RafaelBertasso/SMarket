import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smarket/screens/product.info.page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/main');
          },
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(106, 199, 199, 199),
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

      // 🔥 LISTA COM STREAM DO FIRESTORE
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('produtos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum produto encontrado.'));
          } 

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data();
              return Container(
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
                child: Row(
                  children: [
                    // Imagem do Produto
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: NetworkImage(data['image_url'] ?? 'https://via.placeholder.com/60'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
          
                    SizedBox(width: 12),
          
                    // Nome e descrição
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data['nome'] ?? 'Produto sem nome',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            data['descricao'] ?? 'Sem descrição.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
          
                    // Preço
                    Container(
                      width: 100,
                      alignment: Alignment.center,
                      child: Text(
                        data['preco'] != null
                            ? 'R\$ ${double.parse(data['preco']).toStringAsFixed(2)}'
                            : 'R\$ 0,00',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
