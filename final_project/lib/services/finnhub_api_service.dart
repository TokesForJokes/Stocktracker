import 'dart:convert';
import 'package:http/http.dart' as http;

class FinnhubApiService {
  static const String apiKey = 'API Key goes here ';
  static const String baseUrl = 'https://finnhub.io/api/v1';

  // Fetch the latest market price
  Future<double> fetchLastPrice(String ticker) async {
    final url = Uri.parse('$baseUrl/quote?symbol=$ticker&token=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['c'] ?? 0.0; // 'c' is the current price
    } else {
      throw Exception('Failed to fetch last price for $ticker: ${response.body}');
    }
  }

  // Fetch historical data for the ticker
  Future<List<Map<String, dynamic>>> fetchHistoricalData(String ticker) async {
    final url = Uri.parse(
      '$baseUrl/stock/candle?symbol=$ticker&resolution=D&count=30&token=$apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final times = jsonResponse['t'] as List;
      final prices = jsonResponse['c'] as List;

      return List.generate(times.length, (index) {
        return {'time': times[index], 'price': prices[index]};
      });
    } else {
      throw Exception(
          'Failed to fetch historical data for $ticker: ${response.body}');
    }
  }
}
