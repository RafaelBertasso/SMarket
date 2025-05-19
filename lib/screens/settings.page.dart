import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _cameraEnabled = false;
  bool _locationEnabled = false;
  bool _notificationsEnabled = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Text(""),
        backgroundColor: Colors.white,
        centerTitle: true, // centraliza o título
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
                // Foto do usuário
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

            // Configurações
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
              (value) {
                setState(() {
                  _cameraEnabled = value;
                });
              },
            ),
            _buildToggleItem(
              Icons.place_outlined,
              'Permitir o Uso da Localização',
              _locationEnabled,
              (value) {
                setState(() {
                  _locationEnabled = value;
                });
              },
            ),
            _buildToggleItem(
              Icons.notifications_none_outlined,
              'Permitir o Envio de Notificações',
              _notificationsEnabled,
              (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
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
              '',
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  minimumSize: const Size.fromHeight(60),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
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
    String routeName,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: InkWell(
        hoverColor: Colors.white,
        onTap: () {
          Navigator.pushNamed(context, routeName);
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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
