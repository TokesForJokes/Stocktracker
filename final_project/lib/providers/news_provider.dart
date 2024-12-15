import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _articles = [];
  List<Map<String, dynamic>> get articles => _articles;

  bool isLoading = false;

  Future<void> fetchStockNews() async {
    const String apiKey = 'JDunWNMcMXBND8wkFqIFqfeuLEexfae40hazYrSb'; 
    const String url =
        'https://api.thenewsapi.com/v1/news/all?api_token=$apiKey&categories=business,finance,stocks&language=en&limit=10';

    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> articlesData = data['data'] ?? []; // Adjusted for API structure

        _articles = articlesData.map((article) {
          return {
            'title': article['title'] ?? 'No Title',
            'newsUrl': article['url'] ?? '',
            'imageUrl': article['image_url'] ?? '', // Adjusted for correct field name
          };
        }).toList();
      } else {
        throw Exception("Failed to fetch stock news: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching stock news: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
