import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ProductAIService {
  ProductAIService();

  Future<Map<String, dynamic>?> predictProduct(Uint8List image) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Chave da API do Gemini não encontrada');
    }

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    final prompt = TextPart(
      'Analise a imagem de um produto e retorne nome, descrição, preço e categoria no formato JSON.\n'
      'Exemplo: {"name": "Arroz Tio João", "description": "Arroz branco tipo 1, pacote de 1kg", "price": "7.99", "category": "Massas"}.\n'
      'As categorias possíveis são: "Açougue", "Bebidas", "Feirinha", "Higiene", "Limpeza", "Massas", "Pet".\n'
      'Se não conseguir identificar algum campo, retorne-o vazio, como {"name": "", "description": "", "price": "", "category": ""}.',
    );

    final imagePart = DataPart('image/jpeg', image);

    try {
      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        return null;
      }

      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) return null;

      final jsonString = text.substring(jsonStart, jsonEnd + 1);
      final parsed = json.decode(jsonString) as Map<String, dynamic>;

      return parsed;
    } catch (e) {
      print(
        'Erro ao prever o produto com a IA, por favor, adicione os dados manualmente.',
      );
      return null;
    }
  }
}
