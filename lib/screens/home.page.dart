import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarket/components/home.components.dart';
import 'package:smarket/components/market.filter.dart';
import 'package:smarket/controllers/home.controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final HomeController controller = HomeController();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSectionHeight = screenHeight * 0.35;

    return ChangeNotifierProvider(
      create: (_) => MarketFilter(),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(211, 233, 248, 1),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 25,
                right: 30,
                top: 25,
                bottom: bottomSectionHeight + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeader(),
                  const SizedBox(height: 24),
                  buildSearchField(context, controller, _searchController),
                  const SizedBox(height: 24),
                  buildCategoriesSection(context, controller),
                ],
              ),
            ),
            buildRecentProductsSection(bottomSectionHeight, controller),
          ],
        ),
      ),
    );
  }
}
