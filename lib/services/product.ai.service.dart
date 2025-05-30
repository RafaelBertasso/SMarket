import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class ProductAIService {
  final String apiKey;

  ProductAIService(this.apiKey);

  Future<Map<String, dynamic>?> predictProduct(Uint8List image) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final prompt = TextPart('Analise a imagem de um produto e retorne nome, descrição e preço no formato JSON. '
      'Se não conseguir identificar, retorne {"name": "", "description": "", "price": ""}.',
    );

    final imagePart = DataPart('image/jpeg', image);

    final response = await model.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

    final text = response.text;
    if (text!.isEmpty) {
      return null;
    }

    try {
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) return null;

      final jsonString = text.substring(jsonStart, jsonEnd + 1);
      return json.decode(jsonString);
    } catch (e) {
      print('Erro ao decodificar JSON: $e');
      return null;
    }
  }
}