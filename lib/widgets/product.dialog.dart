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
        title: Text('Confirmar Produto', style: GoogleFonts.inter()),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: tempName,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  onSaved: (value) => tempName = value ?? '',
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Obrigatório' : null,
                ),
                TextFormField(
                  initialValue: tempDescription,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  onSaved: (value) => tempDescription = value ?? '',
                ),
                TextFormField(
                  initialValue: tempPrice,
                  decoration: const InputDecoration(labelText: 'Preço'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => tempPrice = value ?? '',
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Obrigatório' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text('Cancelar', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                Navigator.of(context).pop({
                  'name': tempName,
                  'description': tempDescription,
                  'price': tempPrice,
                });
              }
            },
            child: Text('Salvar', style: GoogleFonts.inter()),
          ),
        ],
      );
    },
  );
}
