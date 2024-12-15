import 'package:flutter/material.dart';
import '../models/stock.dart';

class WatchlistProvider with ChangeNotifier {
  final List<Stock> _watchlist = [];

  List<Stock> get watchlist => _watchlist;

  void setWatchlist(List<Stock> stocks) {
    _watchlist.clear();
    _watchlist.addAll(stocks);
    notifyListeners();
  }

  void addStock(Stock stock) {
    _watchlist.add(stock);
    notifyListeners();
  }

  void removeStock(Stock stock) {
    _watchlist.remove(stock);
    notifyListeners();
  }
}
