import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/investment_provider.dart';
import 'stock_detail_screen.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({Key? key}) : super(key: key);

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  late InvestmentProvider _investmentProvider;

  @override
  void initState() {
    super.initState();
    _investmentProvider = Provider.of<InvestmentProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // Unsubscribe from symbols when the screen is disposed
    _investmentProvider.unsubscribeFromSymbols(['AAPL', 'GOOGL', 'AMZN']);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvestmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Real-Time Stocks",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: provider.fetchSearchResults, // Use fetchSearchResults from provider
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Search Stocks',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent),
                ),
              ),
            ),
          ),
          // Stock List
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.greenAccent,
                    ),
                  )
                : provider.searchResults.isEmpty && provider.stocks.isEmpty
                    ? const Center(
                        child: Text(
                          "No stocks available.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.searchResults.isNotEmpty
                            ? provider.searchResults.length
                            : provider.stocks.length,
                        itemBuilder: (context, index) {
                          final stock = provider.searchResults.isNotEmpty
                              ? provider.searchResults[index]
                              : provider.stocks[index];

                          // Safely extract values, ensuring no nulls are used
                          final String symbol = stock['symbol'] ?? 'Unknown';
                          final double price = stock['price'] ?? 0.0;
                          final double change = stock['change'] ?? 0.0;
                          final bool isGain = change >= 0;

                          return ListTile(
                            leading: Icon(
                              isGain ? Icons.trending_up : Icons.trending_down,
                              color: isGain
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                            ),
                            title: Text(
                              symbol,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              "Price: \$${price.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Text(
                              isGain
                                  ? "+${change.toStringAsFixed(2)}%"
                                  : "${change.toStringAsFixed(2)}%",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isGain
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                              ),
                            ),
                            onTap: () {
                              // Navigate to Stock Detail Screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      StockDetailScreen(stock: stock),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
