import 'package:flutter/material.dart';
import 'package:smarket/screens/smarket.app.page.dart';
import 'package:firebase_core/firebase_core.dart';

const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyBwEhZIfATyFm1sztHX7SLhzaiC7qRDSPI",
  authDomain: "smarket-2fc3c.firebaseapp.com",
  projectId: "smarket-2fc3c",
  storageBucket: "smarket-2fc3c.firebasestorage.app",
  messagingSenderId: "723604083154",
  appId: "1:723604083154:web:cbf8ac37947739592b380b",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(SMarketApp());
}