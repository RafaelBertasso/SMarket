import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smarket/components/product.dialog.dart';
import 'package:smarket/controllers/markets.controller.dart';
import 'package:smarket/models/currency.input.formatter.dart';
import 'package:smarket/services/firestore.service.dart';
import 'package:smarket/services/product.ai.service.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  XFile? photo;
  Size? size;
  bool isLoading = false;

  late final ProductAIService aiService;
  final firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    aiService = ProductAIService();
    _loadCameras();
  }

  _loadCameras() async {
    try {
      cameras = await availableCameras();
      _startCamera();
    } on CameraException catch (e) {
      print(e.description);
    }
  }

  _startCamera() {
    if (cameras.isEmpty) {
      print("Câmera não encontrada");
    } else {
      _previewCamera(cameras.first);
    }
  }

  _previewCamera(CameraDescription camera) async {
    cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await cameraController!.initialize();
    } on CameraException catch (e) {
      print(e.description);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void refazerFoto() {
    setState(() {
      photo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: Text(""),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        title: Text(
          'Escaneie o Produto',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[900],
          child: Center(child: _arquivoWidget()),
        ),
      ),
    );
  }

  Widget _arquivoWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size!.width - 50,
          height: size!.height - (size!.height / 3),
          child:
              photo == null
                  ? _cameraPreviewWidget()
                  : Stack(
                    children: [
                      Image.file(File(photo!.path), fit: BoxFit.contain),
                      if (isLoading) Center(child: CircularProgressIndicator()),
                    ],
                  ),
        ),
        if (photo == null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton.icon(
              onPressed: _showManualEntryDialog,
              icon: Icon(Icons.edit),
              label: Text(
                'Preencher Manualmente',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: refazerFoto,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'Refazer Foto',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => processPhoto,
                  icon: const Icon(Icons.check_circle),
                  label: Text(
                    'Processar',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cameraPreviewWidget() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Text(
        'Câmera não disponível',
        style: GoogleFonts.inter(color: Colors.white),
      );
    } else {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [CameraPreview(cameraController!), _botaoCapturaWidget()],
      );
    }
  }

  Widget _botaoCapturaWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: CircleAvatar(
        radius: 32,
        backgroundColor: const Color.fromARGB(112, 0, 0, 0),
        child: IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.white,
          iconSize: 30,
          onPressed: tirarFoto,
        ),
      ),
    );
  }

  void tirarFoto() async {
    if (cameraController != null && cameraController!.value.isInitialized) {
      try {
        XFile file = await cameraController!.takePicture();
        if (mounted) setState(() => photo = file);
      } on CameraException catch (e) {
        print(e.description);
      }
    }
  }

  Future<void> processPhoto() async {
    if (photo == null) return;
    setState(() {
      isLoading = true;
    });

    try {
      final bytes = await File(photo!.path).readAsBytes();
      final productData = await aiService.predictProduct(bytes);

      if (productData != null) {
        final result = await showProductDialog(
          context,
          name: productData['name'] ?? 'Nome do produto não encontrado',
          description: productData['description'] ?? 'Descrição não encontrada',
          price: productData['price'] ?? 'Preço não encontrado',
        );

        if (result != null) {
          await firestoreService.addProduct(
            name: result['name'] ?? '',
            description: result['description'] ?? '',
            price: result['price'] ?? '',
          );

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Produto salvo com sucesso!')));
          refazerFoto();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível identificar o produto')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showManualEntryDialog() {
    final formKey = GlobalKey<FormState>();
    final priceController = TextEditingController();
    final marketController = TextEditingController();
    final categoryController = TextEditingController();

    final List<String> categories = [
      'Açougue',
      'Bebidas',
      'Feirinha',
      'Higiene',
      'Limpeza',
      'Massas',
      'Pet',
    ];

    String? name;
    String? description;
    String? price;
    String? market;
    String? category;

    Future<List<String>> _fetchMarkets(String query) async {
      try {
        final snapshot =
            await FirebaseFirestore.instance
                .collection('produtos')
                .where('mercado', isGreaterThanOrEqualTo: query)
                .where('mercado', isLessThanOrEqualTo: '$query\uf8ff')
                .limit(5)
                .get();

        final markets =
            snapshot.docs
                .map((doc) => doc['mercado'] as String)
                .toSet()
                .toList();

        return markets;
      } catch (e) {
        debugPrint('Erro ao buscar mercados: $e');
        return [];
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Adicionar Produto',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Campo Nome
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nome do Produto',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.shopping_basket),
                      ),
                      style: GoogleFonts.inter(),
                      onSaved: (value) => name = value,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Campo obrigatório'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Descrição (opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.description),
                      ),
                      style: GoogleFonts.inter(),
                      onSaved: (value) => description = value,
                    ),
                    const SizedBox(height: 16),

                    // Campo Categoria (Autocomplete)
                    DropdownButtonFormField<String>(
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
                      onChanged: (value) {
                        category = value;
                      },
                      validator:
                          (value) => value == null ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),

                    // Campo Mercado (Autocomplete)
                    TextFormField(
                      controller: marketController,
                      decoration: InputDecoration(
                        labelText: 'Mercado',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.store),
                      ),
                      onSaved: (value) => market = value,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Campo obrigatório'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Campo Preço
                    TextFormField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Preço',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CurrencyInputFormatter(),
                      ],
                      onSaved: (value) => price = value,
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
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.grey[200],
                            ),
                            onPressed: () => Navigator.of(context).pop(),
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
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();

                                final numberPrice = double.tryParse(
                                  price!.replaceAll(RegExp(r'[^\d]'), ''),
                                );
                                final finalPrice = (numberPrice! / 100)
                                    .toStringAsFixed(2);

                                try {
                                  await FirebaseFirestore.instance
                                      .collection('produtos')
                                      .add({
                                        'nome': name ?? '',
                                        'descricao': description ?? '',
                                        'mercado': market ?? '',
                                        'categoria':
                                            category?.toLowerCase() ?? 'outros',
                                        'preco': finalPrice.toString(),
                                        'dataAdicionado':
                                            FieldValue.serverTimestamp(),
                                      });

                                  if (mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Produto adicionado com sucesso!',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erro ao salvar: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: Text(
                              'Salvar',
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

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
