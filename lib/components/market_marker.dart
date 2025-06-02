import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:smarket/components/market_details_dialog.dart';

class MarketMarker extends StatelessWidget {
  final String name;
  final LatLng location;
  final Function(LatLng) onRouteRequested;

  const MarketMarker({
    super.key,
    required this.name,
    required this.location,
    required this.onRouteRequested,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final address = await onRouteRequested(location);
        showDialog(
          context: context,
          builder:
              (context) => MarketDetailsDialog(
                marketName: name,
                address: address,
                onRouteRequested: () => onRouteRequested(location),
              ),
        );
      },
      child: const Icon(Icons.shopping_cart, color: Colors.blue, size: 30),
    );
  }
}
