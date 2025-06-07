import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smarket/components/custom.button.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();
  final txtName = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);

  Future<void> _register(BuildContext context) async {
    if (txtPassword.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('A senha deve ter pelo menos 6 caracteres')),
      );
      return;
    }

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: txtEmail.text,
        password: txtPassword.text,
      );
      await credential.user!.updateDisplayName(txtName.text);

      Navigator.of(context)
        ..pop()
        ..pushReplacementNamed('/main');
    } on FirebaseAuthException catch (e) {
      final snackBar = SnackBar(
        content: Text('Erro ao criar conta: ${e.message}'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(20),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                Row(
                  children: [
                    Text(
                      'Crie sua conta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextField(
                      controller: txtEmail,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextField(
                      controller: txtName,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _obscurePassword,
                      builder: (context, value, child) {
                        return TextField(
                          controller: txtPassword,
                          obscureText: value,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Senha',
                            suffixIcon: IconButton(
                              icon: Icon(
                                value ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                _obscurePassword.value =
                                    !_obscurePassword.value;
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                CustomButton(
                  text: 'Registrar',
                  onPressed: () {
                    _register(context);
                  },
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.grey, thickness: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              'Ou faça login clicando abaixo',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: Colors.grey, thickness: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Já possui uma conta?',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
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
