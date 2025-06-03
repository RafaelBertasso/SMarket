import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smarket/components/product.dialog.dart';
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
        centerTitle: true, // centraliza o título
        title: Text(
          'Escaneie o Produto',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[900],
        child: Center(child: _arquivoWidget()),
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
    showDialog(
      context: context,
      builder: (context) {
        final _formKey = GlobalKey<FormState>();
        String? name;
        String? description;
        String? price;
        return AlertDialog(
          title: Text('Preencher Produto', style: GoogleFonts.inter()),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nome do Produto'),
                    onSaved: (value) => name = value,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Campo obrigatório'
                                : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Descrição'),
                    onSaved: (value) => description = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Preço'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => price = value,
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: GoogleFonts.inter()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  await FirebaseFirestore.instance.collection('produtos').add({
                    'nome': name ?? '',
                    'descricao': description ?? '',
                    'preco': price ?? '',
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Produto inserido manualmente!')),
                  );
                }
              },
              child: Text('Salvar', style: GoogleFonts.inter()),
            ),
          ],
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
