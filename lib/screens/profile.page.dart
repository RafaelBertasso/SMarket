import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Dados Pessoais',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Text(
                'Permissões',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            _buildMenuItem(Icons.camera_alt_outlined, 'Uso da Câmera'),
            _buildMenuItem(Icons.place_outlined, 'Uso da Localização'),
            _buildMenuItem(Icons.notifications_none_outlined, 'Notificações'),
            _buildMenuItem(Icons.delete_outline_rounded, 'Deletar Conta'),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 10),
      child: InkWell(
        onTap: () {
          // Funcionalidade do botão
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color.fromRGBO(245, 245, 255, 1),
              child: Icon(icon, color: Colors.black),
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
}
