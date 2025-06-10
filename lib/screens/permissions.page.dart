import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Permissões',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 60,
                  color: Color.fromRGBO(211, 233, 248, 1),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Sobre as Permissões',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Este aplicativo solicita permissões de Câmera e Localização para funcionar corretamente. Nenhum dado pessoal é coletado ou utilizado para fins econômicos.',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[800]),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),
              Text(
                'Por que pedimos essas permissões?',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 24, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Câmera: utilizada apenas para recursos internos do app, como captura das imagens de promoções.',
                      style: GoogleFonts.inter(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.place_outlined, size: 24, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Localização: utilizada para funcionalidades que dependem da sua posição, como sugestões de mercados e mapeamento.',
                      style: GoogleFonts.inter(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(245, 245, 255, 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Garantimos que nenhuma informação pessoal será usada para fins comerciais, nem compartilhada com terceiros.',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
