import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _cameraEnabled = false;
  bool _locationEnabled = false;
  final _notificationsEnabled = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
    _checkLocationPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    setState(() {
      _cameraEnabled = status.isGranted;
    });
  }

  Future<void> _toggleCamera(bool value) async {
    if (value) {
      final status = await Permission.camera.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Permissão de câmera negada')));
      }
    } else {
      await Permission.camera.request();
      await Permission.camera.shouldShowRequestRationale;
    }
    setState(() async {
      _cameraEnabled = value && (await Permission.camera.status).isGranted;
    });
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    setState(() {
      _locationEnabled = status.isGranted;
    });
  }

  Future<void> _toggleLocation(bool value) async {
    if (value) {
      final status = await Permission.location.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissão de localização negada')),
        );
      }
    } else {
      await Permission.location.request();
      await Permission.location.shouldShowRequestRationale;
    }

    setState(() async {
      _locationEnabled = value && (await Permission.location.status).isGranted;
    });
  }

  void _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmar exclusão'),
            content: Text('Tem certeza que deseja excluir sua conta?'),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Deletar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await user?.delete();
        await _auth.signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Faça login novamente para excluir sua conta'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir conta: ${e.message}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Text(""),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Meu Perfil',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color.fromRGBO(211, 233, 248, 1),
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 53.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? 'Nome não cadastrado',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'E-mail não cadastrado',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 15),

            Divider(
              color: const Color.fromRGBO(237, 237, 237, 1),
              thickness: 2,
              indent: 20,
              endIndent: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Configurações',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _buildToggleItem(
              Icons.camera_alt_outlined,
              'Permitir o Uso da Câmera',
              _cameraEnabled,
              _toggleCamera,
            ),
            _buildToggleItem(
              Icons.place_outlined,
              'Permitir o Uso da Localização',
              _locationEnabled,
              _toggleLocation,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Perfil',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _buildMenuItem(
              context,
              Icons.person_outline_outlined,
              'Dados Pessoais',
              '/profile',
            ),

            _buildMenuItem(
              context,
              Icons.delete_outline_rounded,
              'Deletar Conta',
              null,
              onTap: _deleteAccount,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  minimumSize: const Size.fromHeight(60),
                ),
                onPressed: () {
                  _auth.signOut().then((_) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Sair',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String? routeName, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: InkWell(
        hoverColor: Colors.white,
        onTap:
            onTap ??
            () {
              if (routeName != null && routeName.isNotEmpty) {
                Navigator.pushNamed(context, routeName);
              }
            },
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color.fromRGBO(245, 245, 255, 1),
              child: Icon(icon, color: const Color.fromARGB(255, 0, 0, 0)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 20, 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color.fromRGBO(245, 245, 255, 1),
            child: Icon(icon, color: const Color.fromARGB(255, 0, 0, 0)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
