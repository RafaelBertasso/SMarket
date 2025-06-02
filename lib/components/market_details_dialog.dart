import 'package:flutter/material.dart';

class MarketDetailsDialog extends StatelessWidget {
  final String marketName;
  final String address;
  final VoidCallback onRouteRequested;

  const MarketDetailsDialog({
    super.key,
    required this.marketName,
    required this.address,
    required this.onRouteRequested,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Text(
        marketName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black87,
        ),
      ),
      content: Text(
        address,
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      ),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 12),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(fontSize: 14)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            onRouteRequested();
          },
          child: const Text('Rota', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
