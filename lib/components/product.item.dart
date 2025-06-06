import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/favorites.provider.dart';

class ProductItem extends StatelessWidget {
  final DocumentSnapshot doc;
  final String? userId;
  final Function(String, bool) onFavoritePressed;
  final Function()? onTap;

  const ProductItem({
    super.key,
    required this.doc,
    required this.userId,
    required this.onFavoritePressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final product = doc.data() as Map<String, dynamic>;

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
          children: [
            Text('R\$ ${product['preco'].toStringAsFixed(2)}'),
            Text(product['mercado']),
          ],
        ),
        trailing: Consumer<FavoritesProvider>(
          builder: (context, favoritesProvider, _) {
            final isFavorited = favoritesProvider.favoriteIds.contains(doc.id);
            return IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red : null,
              ),
              onPressed: () => favoritesProvider.toggleFavorite(doc.id),
            );
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
