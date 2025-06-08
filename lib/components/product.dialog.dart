import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smarket/controllers/markets.controller.dart';
import 'package:smarket/models/currency.input.formatter.dart';

Future<Map<String, dynamic>?> showProductDialog(
  BuildContext context, {
  required MarketsController marketsController,
  required String name,
  required String description,
  required String price,
  String category = 'outros',
  String market = '',
}) {
  final formKey = GlobalKey<FormState>();
  final priceController = TextEditingController(text: price);
  ValueNotifier<Map<String, dynamic>?> selectedMarket = ValueNotifier(null);

  final List<String> categories = [
    'Açougue',
    'Bebidas',
    'Feirinha',
    'Higiene',
    'Limpeza',
    'Massas',
    'Pet',
    'Outros',
  ];

  String formatCategory(String cat) {
    if (cat.isEmpty) return 'Outros';
    return cat[0].toUpperCase() + cat.substring(1).toLowerCase();
  }

  String tempName = name;
  String tempDescription = description;
  String tempPrice = price;
  String? tempCategory = formatCategory(category);
  String tempMarket = market;

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Confirmar Detalhes do Produto',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(
                      labelText: 'Nome do Produto',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.shopping_basket),
                    ),
                    style: GoogleFonts.inter(),
                    onSaved: (value) => tempName = value ?? '',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Campo obrigatório'
                                : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    initialValue: description,
                    decoration: InputDecoration(
                      labelText: 'Descrição (opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                    style: GoogleFonts.inter(),
                    onSaved: (value) => tempDescription = value ?? '',
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: tempCategory,
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items:
                        categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (value) => tempCategory = value,
                    validator:
                        (value) => value == null ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),

                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: marketsController.getNearbyMarkets(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final markets = snapshot.data ?? [];

                      if (market.isNotEmpty && markets.isNotEmpty) {
                        final existingMarket = markets.firstWhere(
                          (m) => m['name'] == market,
                          orElse: () => {},
                        );

                        if (existingMarket.isNotEmpty) {
                          selectedMarket.value = existingMarket;
                        } else {
                          markets.insert(0, {
                            'name': market,
                            'distance': 0,
                            'location': null,
                          });
                        }
                      }

                      return ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: selectedMarket,
                        builder: (context, value, child) {
                          return SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsetsGeometry.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: DropdownButtonFormField<
                                      Map<String, dynamic>
                                    >(
                                      value: value,
                                      decoration: InputDecoration(
                                        labelText: 'Mercado',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        prefixIcon: const Icon(Icons.store),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                      ),
                                      items: [
                                        const DropdownMenuItem(
                                          value: null,
                                          child: Text('Escolha um mercado'),
                                        ),
                                        ...markets.map((market) {
                                          return DropdownMenuItem<
                                            Map<String, dynamic>
                                          >(
                                            value: market,
                                            child: Text(
                                              '${market['name']} - ${market['address']}',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          );
                                        }),
                                      ],
                                      onChanged: (newValue) {
                                        selectedMarket.value = newValue;
                                      },
                                      validator:
                                          (value) =>
                                              value == null
                                                  ? 'Campo obrigatório'
                                                  : null,
                                      isExpanded: true,
                                      dropdownColor: Colors.white,
                                      elevation: 2,
                                      icon: const Icon(Icons.arrow_drop_down),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  if (markets.isEmpty)
                                    Text(
                                      'Nenhum mercado encontrado próximo',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Preço',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyInputFormatter(),
                    ],
                    onSaved: (value) => tempPrice = value ?? '',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Campo obrigatório'
                                : null,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.grey[200],
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.inter(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              final marketValue =
                                  selectedMarket.value?['name'] ?? '';
                              final parts = marketValue.split(' - ');
                              final marketName = parts[0].trim();
                              final marketAddress =
                                  parts.length > 1 ? parts[1].trim() : '';
                              Navigator.pop(context, {
                                'name': tempName,
                                'description': tempDescription,
                                'price': tempPrice,
                                'category': tempCategory?.toLowerCase(),
                                'market': '$marketName - $marketAddress',
                              });
                            }
                          },
                          child: Text(
                            'Confirmar',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
