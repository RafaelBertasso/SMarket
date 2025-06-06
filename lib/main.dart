import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:smarket/providers/favorites.provider.dart';
import 'package:smarket/components/market.filter.dart';
import 'package:smarket/firebase_options.dart';
import 'package:smarket/screens/smarket.app.page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketFilter()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: SMarketApp(),
    ),
  );
}
