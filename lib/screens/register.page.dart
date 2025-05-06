import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 5,
          children: [
            Row(
              children: [
                Text(
                  'Crie sua conta',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Crie uma conta para começar a economizar',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.all(40)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Digite seu e-mail',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'E-mail',
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nome completo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nome',
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Digite sua senha',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Senha',
                    suffixIcon: Icon(Icons.visibility_off),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Registrar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Ou acesse usando',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                // Ação ao clicar no botão do Google
              },
              icon: Image.asset(
                'assets/images/google_icon.png', // Certifique-se de ter esse ícone no projeto
                height: 24,
                width: 24,
              ),
              label: Text(
                'Entrar com Google',
                style: TextStyle(color: Colors.black),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                side: BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Já possui uma conta?'),
                TextButton(
                  onPressed: () {
                    // Navega para a tela de registro
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
