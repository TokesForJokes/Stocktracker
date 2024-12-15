import 'dart:async';

import 'package:final_project/providers/investment_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class StockList extends StatefulWidget {
  @override
  _StockListState createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  final List<String> _tickers = ['AAPL', 'TSLA', 'GOOGL']; // List of stock tickers
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<InvestmentProvider>(context, listen: false);

    // Connect to WebSocket and fetch fallback prices
    provider.connectWebSocket(_tickers);
    provider.fetchLastClosingPrices(_tickers);

    // Set up a periodic fallback to fetch last closing prices
    _fallbackTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (!provider.isConnected) {
        provider.fetchLastClosingPrices(_tickers);
      }
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvestmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Prices'),
      ),
      body: ListView.builder(
        itemCount: provider.stocks.length,
        itemBuilder: (context, index) {
          final stock = provider.stocks[index];
          return ListTile(
            title: Text(stock['symbol']),
            subtitle: Text(
              '\$${stock['price']?.toStringAsFixed(2) ?? 'N/A'}',
            ),
          );
        },
      ),
    );
  }
}
