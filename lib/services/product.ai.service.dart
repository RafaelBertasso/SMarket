import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class ProductAIService {
  final String apiKey;

  ProductAIService(this.apiKey);

  Future<Map<String, dynamic>?> predictProduct(Uint8List image) async {
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    final prompt = TextPart(
      'Analise a imagem de um produto e retorne nome, descrição e preço no formato JSON.\n'
      'Exemplo: {"name": "Arroz Tio João", "description": "Arroz branco tipo 1, pacote de 1kg", "price": "7.99"}.\n'
      'Se não conseguir identificar, retorne {"name": "", "description": "", "price": ""}.',
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
      final parsed = json.decode(jsonString);

      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
      return null;
    } catch (e) {
      print(
        'Erro ao prever o produto com a IA, por favor, adicione os dados manualmente.',
      );
      return null;
    }
  }
}
