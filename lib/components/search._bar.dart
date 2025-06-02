import 'package:flutter/material.dart';

import 'package:latlong2/latlong.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final List<Map<String, dynamic>> markets;
  final Function(String) onSearchSubmitted;
  final Function(LatLng) onMarketSelected;

  const SearchBar({
    super.key,
    required this.controller,
    required this.markets,
    required this.onSearchSubmitted,
    required this.onMarketSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return markets
              .map((market) => market['name'].toString())
              .where(
                (name) => name.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              )
              .toList();
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          this.controller.text = controller.text;
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Digite o nome do mercado',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onSubmitted: onSearchSubmitted,
          );
        },
        onSelected: (String selectedName) async {
          final selectedMarket = markets.firstWhere(
            (market) => market['name'] == selectedName,
          );
          onMarketSelected(selectedMarket['location']);
        },
      ),
    );
  }
}
