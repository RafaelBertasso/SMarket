import 'package:flutter/material.dart';
import 'package:smarket/components/navbar.dart';
import 'package:smarket/screens/forgot.password.page.dart';
import 'package:smarket/screens/home.page.dart';
import 'package:smarket/screens/login.page.dart';
import 'package:smarket/screens/register.page.dart';
import 'package:smarket/screens/verify.page.dart';
import 'package:smarket/screens/profile.page.dart';
import 'package:smarket/screens/location.page.dart';

class SMarketApp extends StatelessWidget {
  const SMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NavBar(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) => NavBar(),
        '/home': (context) => HomePage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/verify': (context) => const VerifyPage(),
        '/profile': (context) => const ProfilePage(),
        '/location': (context) => const LocationPage(),
      },
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
    );
  }
}
