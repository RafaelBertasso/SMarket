import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:smarket/services/product.ai.service.dart';
import 'package:smarket/services/firestore.service.dart';
import 'package:smarket/widgets/product.dialog.dart';
import 'package:smarket/widgets/product.form.dialog.dart';

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
    final apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    aiService = ProductAIService(apiKey);
    _loadCameras();
  }

  _loadCameras() async {
    try {
      cameras = await availableCameras();
      _startCamera();
    } catch (e) {
      print(e);
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
    } catch (e) {
      print(e);
    }

    if (mounted) setState(() {});
  }

  void refazerFoto() {
    setState(() {
      photo = null;
    });
  }

  Future<void> processPhoto() async {
    if (photo == null) return;

    try {
      setState(() => isLoading = true);

      final bytes = await File(photo!.path).readAsBytes();
      final jsonData = await aiService.predictProduct(bytes);

      if (jsonData != null) {
        final result = await showProductDialog(
          context,
          name: jsonData['name'] ?? '',
          description: jsonData['description'] ?? '',
          price: jsonData['price'] ?? '',
        );

        if (result != null) {
          await firestoreService.addProduct(
            name: result['name'] ?? '',
            description: result['description'] ?? '',
            price: result['price'] ?? '',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produto salvo com sucesso!')),
          );

          setState(() => photo = null);
        }
      } else {
        throw Exception('Não consegui identificar o produto.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
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
      mainAxisAlignment: MainAxisAlignment.center, //alterar altura da camera
      children: [
        Container(
          width: size!.width - 50,
          height: size!.height - (size!.height / 3),
          child:
              photo == null
                  ? _cameraPreviewWidget()
                  : Image.file(File(photo!.path), fit: BoxFit.contain),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(context: context, builder: (context) => const ProductFormDialog());
            },
            icon: const Icon(Icons.edit),
            label: Text(
              'Preencher Manualmente',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
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
        ),
        if (photo != null)
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
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle),
                  label: Text(
                    'Finalizar',
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

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
