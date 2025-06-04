import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smarket/components/navbar.dart';
import 'package:smarket/screens/category.page.dart';
import 'package:smarket/screens/favorites.page.dart';
import 'package:smarket/screens/forgot.password.page.dart';
import 'package:smarket/screens/login.page.dart';
import 'package:smarket/screens/register.page.dart';
import 'package:smarket/screens/profile.page.dart';
import 'package:smarket/screens/location.page.dart';

class SMarketApp extends StatelessWidget {
  SMarketApp({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NavBar(),
      routes: {
        '/login': (context) => LoginPage(),
        '/main': (context) => NavBar(),
        '/register': (context) => RegisterPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/profile': (context) => ProfilePage(),
        '/location': (context) => LocationPage(),
        '/category': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return CategoryPage(categoryName: args['categoryName']);
        },
        '/favorites': (context) => FavoritesPage(),
      },
      initialRoute: _auth.currentUser == null ? '/login' : '/main',
      debugShowCheckedModeBanner: false,
    );
  }
}
