import 'package:flutter/material.dart';
import 'package:smarket/firebase_options.dart';
import 'package:smarket/screens/smarket.app.page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(SMarketApp());
}