import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/investment_provider.dart';
import 'stock_detail_screen.dart';

class StockSearchScreen extends StatefulWidget {
  const StockSearchScreen({Key? key}) : super(key: key);

  @override
  State<StockSearchScreen> createState() => _StockSearchScreenState();
}

class _StockSearchScreenState extends State<StockSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvestmentProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade800,
            hintText: "Search for a stock...",
            hintStyle: const TextStyle(color: Colors.white54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
          ),
          onChanged: (query) {
            provider.fetchSearchResults(query); 
          },
        ),
      ),
      body: Column(
        children: [
          // Search Results
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.greenAccent,
                    ),
                  )
                : provider.searchResults.isEmpty
                    ? const Center(
                        child: Text(
                          "No results found.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.searchResults.length,
                        itemBuilder: (context, index) {
                          final stock = provider.searchResults[index];
                          return Card(
                            color: Colors.grey.shade900,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(
                                stock['symbol'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              subtitle: Text(
                                stock['description'] ?? 'No description',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  color: Colors.greenAccent),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StockDetailScreen(stock: stock),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
