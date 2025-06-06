import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smarket/models/product.info.model.dart';

class ProductController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ProductModel> fetchProduct(String productId) async {
    final doc = await _firestore.collection('produtos').doc(productId).get();
    if (!doc.exists) {
      throw Exception('Produto não encontrado');
    }
    return ProductModel.fromFirestore(doc);
  }

  String getCategoryImage(String? category) {
    if (category == null) return 'assets/images/default.png';

    switch (category.toLowerCase()) {
      case 'açougue':
      case 'acougue':
        return 'assets/images/acougue.png';
      case 'bebidas':
        return 'assets/images/bebidas.png';
      case 'feirinha':
        return 'assets/images/feirinha.png';
      case 'higiene':
        return 'assets/images/higiene.png';
      case 'limpeza':
        return 'assets/images/limpeza.png';
      case 'massas':
        return 'assets/images/massas.png';
      case 'pet':
        return 'assets/images/pet.png';
      default:
        return 'assets/images/default.png';
    }
  }

  String formatDate(dynamic dateField) {
    if (dateField == null) return 'Data não informada';

    DateTime date;
    if (dateField is Timestamp) {
      date = dateField.toDate();
    } else if (dateField is String) {
      try {
        date = DateTime.parse(dateField);
      } catch (e) {
        return dateField;
      }
    } else {
      return dateField.toString();
    }

    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
