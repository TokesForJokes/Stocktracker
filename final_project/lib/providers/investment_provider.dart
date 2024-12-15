import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class InvestmentProvider with ChangeNotifier {
  static const String _apiKey = 'ctee8q9r01qt478lnda0ctee8q9r01qt478lndag';
  static const String _webSocketUrl = 'wss://ws.finnhub.io';
  static const String _baseApiUrl = 'https://finnhub.io/api/v1';

  late final WebSocketChannel _channel;
  final Map<String, double> _stockPrices = {}; // Stores current stock prices
  final List<Map<String, dynamic>> _stocks = []; // List of stock details
  bool _isConnected = false;

  // Portfolio Data
  final Map<String, dynamic> _portfolio = {
    'AAPL': {'quantity': 10, 'purchasePrice': 145.0},
    'GOOGL': {'quantity': 5, 'purchasePrice': 2800.0},
    'AMZN': {'quantity': 8, 'purchasePrice': 3450.0},
  };
  double _portfolioValue = 0.0;
  double _portfolioGain = 0.0;

  // Real-Time Graph Data
  final Map<String, List<FlSpot>> _graphData = {}; // Stores real-time graph data for each ticker

  // Search Results
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> get searchResults => _searchResults;

  // Loading State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Getters
  List<Map<String, dynamic>> get stocks => _stocks;
  Map<String, double> get stockPrices => _stockPrices;
  bool get isConnected => _isConnected;
  Map<String, dynamic> get portfolio => _portfolio;
  double get portfolioValue => _portfolioValue;
  double get portfolioGain => _portfolioGain;

  // Fetch real-time graph spots for a specific ticker
  List<FlSpot> realTimeGraphSpots(String ticker) {
    return _graphData[ticker] ?? []; // Return the list of FlSpot, or an empty list if no data exists
  }

  // Update real-time graph data
  void updateGraphData(String ticker, double price, DateTime time) {
    final timestamp = time.millisecondsSinceEpoch.toDouble();
    final spot = FlSpot(timestamp, price);

    if (_graphData.containsKey(ticker)) {
      _graphData[ticker]!.add(spot);

      // Limit to the last 60 points for better visualization
      if (_graphData[ticker]!.length > 60) {
        _graphData[ticker] = _graphData[ticker]!.sublist(_graphData[ticker]!.length - 60);
      }
    } else {
      _graphData[ticker] = [spot];
    }

    notifyListeners();
  }

  // Fetch stock search results
  Future<void> fetchSearchResults(String query) async {
    _isLoading = true;
    notifyListeners();

    if (query.isEmpty) {
      _searchResults = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse('$_baseApiUrl/search?q=$query&token=$_apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _searchResults = (data['result'] as List)
            .map((item) => {
                  'symbol': item['symbol'] ?? 'Unknown',
                  'description': item['description'] ?? '',
                })
            .toList();
      } else {
        throw Exception('Failed to fetch search results');
      }
    } catch (error) {
      debugPrint('Error fetching search results: $error');
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Connect to WebSocket and subscribe to stock symbols
  void connectWebSocket(List<String> tickers) {
    _channel = WebSocketChannel.connect(
      Uri.parse('$_webSocketUrl?token=$_apiKey'),
    );

    // Subscribe to tickers
    for (var ticker in tickers) {
      _channel.sink.add(jsonEncode({'type': 'subscribe', 'symbol': ticker}));
      debugPrint('Subscribed to $ticker');
    }

    _isConnected = true;
    notifyListeners();

    // Listen for WebSocket updates
    _channel.stream.listen(
      (message) {
        final data = jsonDecode(message);
        if (data['type'] == 'trade') {
          for (var trade in data['data']) {
            final symbol = trade['s'];
            final price = trade['p'] as double;
            _updateStockData(symbol, price);
            updateGraphData(symbol, price, DateTime.now()); // Update graph data
          }
        }
      },
      onError: (error) {
        debugPrint('WebSocket Error: $error');
        _isConnected = false;
        notifyListeners();
      },
      onDone: () {
        debugPrint('WebSocket connection closed.');
        _isConnected = false;
        notifyListeners();
      },
    );
  }

  // Unsubscribe from specific stock symbols
  void unsubscribeFromSymbols(List<String> tickers) {
    if (_isConnected && _channel != null) {
      for (var ticker in tickers) {
        _channel.sink.add(jsonEncode({'type': 'unsubscribe', 'symbol': ticker}));
        debugPrint('Unsubscribed from $ticker');
      }
    } else {
      debugPrint('Cannot unsubscribe: WebSocket is not connected.');
    }
  }

  // Fetch last closing prices using REST API
  Future<void> fetchLastClosingPrices(List<String> tickers) async {
    for (var ticker in tickers) {
      try {
        final price = await _fetchLastPrice(ticker);
        debugPrint('Last closing price for $ticker: $price');
        _updateStockData(ticker, price);
        updateGraphData(ticker, price, DateTime.now()); // Update graph data
      } catch (e) {
        debugPrint('Error fetching last closing price for $ticker: $e');
      }
    }
    notifyListeners();
  }

  // Fetch last price from REST API
  Future<double> _fetchLastPrice(String ticker) async {
    final url = Uri.parse('$_baseApiUrl/quote?symbol=$ticker&token=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['c'] ?? 0.0; // 'c' is the last closing price
    } else {
      throw Exception('Failed to fetch last price for $ticker: ${response.body}');
    }
  }

  // Fetch and calculate portfolio data
  void fetchPortfolioData() {
    double totalValue = 0.0;
    double totalGain = 0.0;

    for (var symbol in _portfolio.keys) {
      final stockPrice = _stockPrices[symbol] ?? 0.0; // Current stock price
      final quantity = _portfolio[symbol]['quantity'] ?? 0;
      final purchasePrice = _portfolio[symbol]['purchasePrice'] ?? 0.0;

      totalValue += stockPrice * quantity; // Calculate current value
      totalGain += (stockPrice - purchasePrice) * quantity; // Calculate gain/loss
    }

    _portfolioValue = totalValue;
    _portfolioGain = totalGain;

    notifyListeners();
  }

  // Update stock data
  void _updateStockData(String symbol, double price) {
    final existingStock = _stocks.firstWhere(
      (stock) => stock['symbol'] == symbol,
      orElse: () => {},
    );

    if (existingStock.isEmpty) {
      _stocks.add({
        'symbol': symbol,
        'price': price,
        'change': 0.0,
      });
    } else {
      final oldPrice = existingStock['price'] ?? 0.0;
      existingStock['price'] = price;
      existingStock['change'] = price - oldPrice;
    }
    fetchPortfolioData(); // Recalculate portfolio data whenever stock data is updated
    notifyListeners();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}