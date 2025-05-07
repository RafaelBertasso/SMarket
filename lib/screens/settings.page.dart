import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true, // centraliza o título
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                // Foto do usuário
                Container(
                  padding: const EdgeInsets.all(2), // Espessura da borda
                  child: const CircleAvatar(radius: 50),
                ),
                // Bolinha do ícone de câmera como botão
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _showPhotoOptions(context),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 15,
                          backgroundColor: Color.fromRGBO(245, 245, 255, 1),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Color.fromRGBO(28, 154, 234, 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Fulano de Tal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'otalfulano@gmail.com',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 15),

            Divider(
              color: const Color.fromRGBO(237, 237, 237, 1),
              thickness: 2,
              indent: 25, // margem à esquerda
              endIndent: 25, // margem à direita
            ),

            // --- Perfil ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Perfil', style: TextStyle()),
              ),
            ),
            _buildMenuItem(Icons.person_outline_outlined, 'Dados Pessoais'),
            _buildMenuItem(Icons.settings_outlined, 'Configurações'),
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

  Widget _buildMenuItem(
    IconData icon,
    String title, //String routeName)
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 10),
      child: InkWell(
        hoverColor: Colors.white, // azul clarinho
        onTap: () {
          //  Navigator.pushNamed(context, routeName); // leva pra tela desejada
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(245, 245, 255, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.blue,
                  ),
                  title: const Text('Tirar foto'),
                  onTap: () {
                    Navigator.pop(context);
                    // lógica da câmera aqui
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.blue,
                  ),
                  title: const Text('Escolher da galeria'),
                  onTap: () {
                    Navigator.pop(context);
                    // lógica da galeria aqui
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
