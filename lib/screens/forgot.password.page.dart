import 'package:flutter/material.dart';
import 'package:smarket/components/custom.button.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 5,
          children: [
            Row(
              children: [
                Text(
                  'Esqueceu a senha?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Insira seu e-mail para receber o código de recuperação',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.all(40)),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'E-mail',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'E-mail',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            CustomButton(text: 'Enviar código', onPressed: () {
              Navigator.pushNamed(context, '/verify');
            }),
          ],
        ),
      ),
    );
  }
}
