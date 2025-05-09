import 'package:flutter/material.dart';
import 'package:smarket/components/custom.button.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Verificação',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Insira o código enviado para o seu e-mail',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (index < 3) {
                              _focusNodes[index + 1].requestFocus();
                            } else {
                              final code =
                                  _controllers.map((e) => e.text).join();
                              if (code.length == 4) {
                                // Aqui você pode adicionar a lógica para verificar o código

                                Future.delayed(Duration(milliseconds: 100), () {
                                  Navigator.pushNamed(context, '/reset');
                                });
                              }
                            }
                          } else if (index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },

                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            CustomButton(
              text: 'Continuar',
              onPressed: () {
                final code = _controllers.map((e) => e.text).join();
                //verificação do código
                Navigator.pushNamed(context, '/reset');
              },
            ),
          ],
        ),
      ),
    );
  }
}
