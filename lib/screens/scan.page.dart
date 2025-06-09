import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:smarket/components/product.dialog.dart';
import 'package:smarket/models/currency.input.formatter.dart';
import 'package:smarket/services/firestore.service.dart';
import 'package:smarket/services/product.ai.service.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  XFile? photo;
  Size? size;
  bool isLoading = false;
  bool _isCameraPermissionGranted = false;
  bool _showCameraPermissionError = false;

  late final ProductAIService aiService;
  final firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    aiService = ProductAIService();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkCameraPermission();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;

    setState(() {
      _isCameraPermissionGranted = status.isGranted;
      _showCameraPermissionError = status.isPermanentlyDenied;
    });

    if (_isCameraPermissionGranted && cameraController == null) {
      await _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        await _previewCamera(cameras.first);
      } else {
        setState(() {
          _showCameraPermissionError = true;
        });
      }
    } catch (e) {
      print('Erro ao carregar câmeras: $e');
      setState(() {
        _showCameraPermissionError = true;
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();

    setState(() {
      _isCameraPermissionGranted = status.isGranted;
      _showCameraPermissionError = status.isPermanentlyDenied;
    });

    if (_isCameraPermissionGranted) {
      await _initializeCamera();
    } else if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog('câmera');
    }
  }

  Future<void> _showPermissionDeniedDialog(String permission) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text('Permissão de $permission necessária'),
            content: Text(
              'Para usar esta funcionalidade, você precisa conceder permissão '
              'de $permission nas configurações do aplicativo.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Abrir Configurações'),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  Future<void> _previewCamera(CameraDescription camera) async {
    cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print('Erro ao iniciar a câmera: $e');
      setState(() {
        _showCameraPermissionError = true;
      });
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
        leading: const Text(""),
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
      body: Container(
        color: Colors.grey[900],
        child: Center(child: _buildMainContent()),
      ),
    );
  }

  Widget _buildMainContent() {
    if (!_showCameraPermissionError && !_isCameraPermissionGranted) {
      return _buildInitialCameraUI();
    }

    if (_showCameraPermissionError) {
      return _buildPermissionErrorWidget('câmera', _requestCameraPermission);
    }

    if (!_isCameraPermissionGranted || cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildCameraUI();
  }

  Widget _buildInitialCameraUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Icon(Icons.camera_alt, size: 100, color: Colors.white),
            const SizedBox(height: 32),
            Text(
              'Escaneie promoções\nem segundos',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aponte a câmera para o produto ou etiqueta de preço para identificar automaticamente',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
            ),
            const Spacer(flex: 3),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _requestCameraPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'INICIAR CÂMERA',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraUI() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size!.width - 50,
            height: size!.height - (size!.height / 3),
            child:
                photo == null
                    ? _cameraPreviewWidget()
                    : Stack(
                      children: [
                        Image.file(File(photo!.path)),
                        if (isLoading)
                          Center(child: CircularProgressIndicator()),
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
                style: _buttonStyle(Colors.blueAccent),
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
                    style: _buttonStyle(Colors.redAccent),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: processPhoto,
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      'Processar',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                    style: _buttonStyle(Colors.green),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildPermissionErrorWidget(String permission, Function onRetry) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 50, color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Permissão de $permission necessária',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Para usar esta funcionalidade, precisamos acessar sua $permission.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => openAppSettings(),
            child: Text(
              'Abrir Configurações',
              style: GoogleFonts.inter(fontSize: 16),
            ),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              await onRetry();
              if (mounted) setState(() {});
            },
            child: Text(
              'Tentar novamente',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
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
          category:
              productData['category']?.toLowerCase() ??
              'Categoria não encontrada',
          market: productData['market'] ?? '',
        );

        if (result != null) {
          final price = double.tryParse(
            result['price']?.replaceAll(RegExp(r'[^\d]'), '') ?? '0',
          );
          final finalPrice = ((price ?? 0) / 100).toStringAsFixed(2);

          await FirebaseFirestore.instance.collection('produtos').add({
            'nome': result['name'] ?? '',
            'descricao': result['description'] ?? '',
            'preco': finalPrice,
            'categoria': result['category']?.toLowerCase() ?? 'outros',
            'mercado': result['market'] ?? '',
            'dataAdicionado': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Produto salvo com sucesso!'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          refazerFoto();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível identificar o produto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro')));
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
}
