import 'package:flutter/material.dart';
import 'package:smarket/screens/home.page.dart';
import 'package:smarket/screens/login.page.dart';
import 'package:smarket/screens/register.page.dart';

class SMarketApp extends StatelessWidget {
  const SMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomePage(),
        '/register': (context) => const RegisterPage(),
      },
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
    );
  }
}