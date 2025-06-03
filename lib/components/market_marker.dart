// market_marker_content.dart
import 'package:flutter/material.dart';

class MarketMarkerContent extends StatelessWidget {
  final VoidCallback onTap;

  const MarketMarkerContent({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(Icons.shopping_cart, color: Colors.blue, size: 30),
    );
  }
}
