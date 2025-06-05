import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:smarket/components/product.dialog.dart';
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
  bool _isLocationPermissionGranted = false;
  bool _showLocationPermissionError = false;

  late final ProductAIService aiService;
  final firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    aiService = ProductAIService();
    // Não solicitamos permissões aqui, apenas quando o usuário tentar usar a câmera
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recarrega as permissões quando o app retornar do background
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    await _checkCameraPermission();
    await _checkLocationPermission();
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

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;

    setState(() {
      _isLocationPermissionGranted = status.isGranted;
      _showLocationPermissionError = status.isPermanentlyDenied;
    });
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

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();

    setState(() {
      _isLocationPermissionGranted = status.isGranted;
      _showLocationPermissionError = status.isPermanentlyDenied;
    });

    if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog('localização');
    }
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
    // Se o usuário ainda não tentou usar a câmera, mostra a UI normal
    if (!_showCameraPermissionError && !_isCameraPermissionGranted) {
      return _buildInitialCameraUI();
    }

    // Se houve erro de permissão
    if (_showCameraPermissionError) {
      return _buildPermissionErrorWidget('câmera', _requestCameraPermission);
    }

    // Se a câmera está carregando
    if (!_isCameraPermissionGranted || cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // UI normal da câmera
    return _buildCameraUI();
  }

  Widget _buildInitialCameraUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 80, color: Colors.white),
        SizedBox(height: 20),
        Text(
          'Pronto para escanear promoções',
          style: GoogleFonts.inter(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            await _requestCameraPermission();
            if (_isLocationPermissionGranted) {
              await _requestLocationPermission();
            }
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          child: Text('Iniciar Câmera', style: GoogleFonts.inter(fontSize: 16)),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: _showManualEntryDialog,
          child: Text(
            'Ou preencha manualmente',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraUI() {
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
                      Image.file(File(photo!.path)),
                      if (isLoading) Center(child: CircularProgressIndicator()),
                    ],
                  ),
        ),
        if (photo == null)
          Padding(
            padding: EdgeInsets.only(top: 16),
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
            padding: EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: refazerFoto,
                  icon: Icon(Icons.refresh),
                  label: Text(
                    'Refazer Foto',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  style: _buttonStyle(Colors.redAccent),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: processPhoto,
                  icon: Icon(Icons.check_circle),
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
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildPermissionErrorWidget(String permission, Function onRetry) {
    return Padding(
      padding: EdgeInsets.all(20),
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
          refazerFoto();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível identificar o produto'),
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
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        String? name;
        String? description;
        String? price;
        return AlertDialog(
          title: Text('Preencher Produto', style: GoogleFonts.inter()),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nome do Produto',
                    ),
                    onSaved: (value) => name = value,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Campo obrigatório'
                                : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    onSaved: (value) => description = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Preço'),
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
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  await FirebaseFirestore.instance.collection('produtos').add({
                    'nome': name ?? '',
                    'descricao': description ?? '',
                    'preco': price ?? '',
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produto inserido manualmente!'),
                    ),
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
}
