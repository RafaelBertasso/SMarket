import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smarket/models/currency.input.formatter.dart';

Future<Map<String, dynamic>?> showProductDialog(
  BuildContext context, {
  required String name,
  required String description,
  required String price,
  String category = 'outros',
  String market = '',
}) {
  final formKey = GlobalKey<FormState>();
  final priceController = TextEditingController(text: price);
  final marketController = TextEditingController(text: market);

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

                  TextFormField(
                    controller: marketController,
                    decoration: InputDecoration(
                      labelText: 'Mercado',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.store),
                    ),
                    onSaved: (value) => tempMarket = value ?? '',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Campo obrigatório'
                                : null,
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
                              Navigator.pop(context, {
                                'name': tempName,
                                'description': tempDescription,
                                'price': tempPrice,
                                'category': tempCategory?.toLowerCase(),
                                'market': tempMarket,
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
