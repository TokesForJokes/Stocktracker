import 'dart:convert';
import 'package:http/http.dart' as http;

class StockService {
  final String _apiKey = "API Key "; 
  final String _baseUrl = "https://finnhub.io/api/v1";

  // Fetch real-time stock data
  Future<Map<String, dynamic>> getStockData(String symbol) async {
    final url = Uri.parse("$_baseUrl/quote?symbol=$symbol&token=$_apiKey");

    try {
      print("Fetching stock data for: $symbol");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          print("Stock Data for $symbol: $data");
          return data;
        } else {
          throw Exception("Empty response received for $symbol.");
        }
      } else if (response.statusCode == 403) {
        throw Exception("403 Error: API key access denied. Check limits or permissions.");
      } else {
        throw Exception("HTTP Error ${response.statusCode}: Failed to fetch data for $symbol.");
      }
    } catch (e) {
      print("Error fetching stock data for $symbol: $e");
      return {}; // Return an empty map in case of failure
    }
  }

  // Search for stocks
  Future<List<dynamic>> searchStocks(String query) async {
    final url = Uri.parse("$_baseUrl/search?q=$query&token=$_apiKey");

    try {
      print("Searching for stocks with query: $query");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] ?? []; // Return stock search results
      } else {
        throw Exception("HTTP Error ${response.statusCode}: Failed to fetch search results.");
      }
    } catch (e) {
      print("Error searching for stocks: $e");
      return []; 
    }
  }

  // Fetch historical stock data for graphs
  Future<List<double>> getStockHistory(String symbol) async {
    final to = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final from = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000;

    final url = Uri.parse(
      "$_baseUrl/stock/candle?symbol=$symbol&resolution=D&from=$from&to=$to&token=$_apiKey",
    );

    try {
      print("Fetching historical data for: $symbol");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['s'] == 'ok' && data['c'] != null) {
          print("Historical Data for $symbol: ${data['c']}");
          return List<double>.from(data['c']); // Closing prices
        } else {
          print("No historical graph data available for $symbol.");
        }
      } else if (response.statusCode == 403) {
        print("HTTP 403: Access Denied for $symbol. Check API key usage.");
      } else {
        print("HTTP Error ${response.statusCode} for $symbol.");
      }
    } catch (e) {
      print("Error fetching historical data for $symbol: $e");
    }
    return []; 
  }
}
