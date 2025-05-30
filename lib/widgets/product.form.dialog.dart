import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smarket/services/firestore.service.dart';

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final firestoreService = FirestoreService();

  String? name;
  String? description;
  String? price;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Preencher Produto', style: GoogleFonts.inter()),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
                onSaved: (value) => name = value,
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                onSaved: (value) => description = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType: TextInputType.number,
                onSaved: (value) => price = value,
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: GoogleFonts.inter()),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              try {
                await firestoreService.addProduct(
                  name: name ?? '',
                  description: description ?? '',
                  price: price ?? '',
                );

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produto inserido manualmente!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: $e')),
                );
              }
            }
          },
          child: Text('Salvar', style: GoogleFonts.inter()),
        ),
      ],
    );
  }
}
