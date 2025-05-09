import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smarket/components/custom.button.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[200],
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      style: ButtonStyle(visualDensity: VisualDensity.compact),
                      onPressed: () {
                        Navigator.pushNamed(context, '/verify');
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Resetar Senha',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Digite sua nova senha',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nova senha',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Senha',
                        suffixIcon: Icon(Icons.visibility_off),
                        counterText:
                            'A senha deve conter no mínimo 8 caracteres',
                      ),
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Confirme sua senha',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Senha',
                        suffixIcon: Icon(Icons.visibility_off),
                        counterText: 'As senhas devem ser iguais',
                      ),
                    ),
                  ],
                ),
              ),
              CustomButton(
                text: 'Verificar',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return Stack(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              color: const Color.fromARGB(132, 0, 0, 0),
                            ),
                          ),
                          DraggableScrollableSheet(
                            initialChildSize: 0.5,
                            minChildSize: 0.5,
                            maxChildSize: 0.5,
                            builder:
                                (_, controller) => Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/success.png',
                                        height: 200,
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Senha alterada com sucesso',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Senha alterada com sucesso! Agora você pode fazer login com sua nova senha!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ),
                        ],
                      );
                    },
                  );
                  Future.delayed(Duration(seconds: 5), () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/login');
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
