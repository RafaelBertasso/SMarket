import 'package:flutter/material.dart';

class MarketFilter extends ChangeNotifier {
  String _selectedMarket = 'Todos';

  String get selectedMarket => _selectedMarket;

  void setMarket(String market) {
    _selectedMarket = market;
    notifyListeners();
  }

  void clearFilter() {
    _selectedMarket = 'Todos';
    notifyListeners();
  }
}
