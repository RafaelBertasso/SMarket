import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<Map<String, String>?> showProductDialog(
  BuildContext context, {
  required String name,
  required String description,
  required String price,
}) {
  final formKey = GlobalKey<FormState>();
  String tempName = name;
  String tempDescription = description;
  String tempPrice = price;

  return showDialog<Map<String, String>>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Confirmar Detalhes do Produto',
          style: GoogleFonts.inter(),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => tempName = value ?? '',
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Campo obrigatório'
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: description,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onSaved: (value) => tempDescription = value ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: price,
                  decoration: const InputDecoration(
                    labelText: 'Preço',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => tempPrice = value ?? '',
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Campo obrigatório'
                              : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                Navigator.pop(context, {
                  'name': tempName,
                  'description': tempDescription,
                  'price': tempPrice,
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(
              'Confirmar',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}
