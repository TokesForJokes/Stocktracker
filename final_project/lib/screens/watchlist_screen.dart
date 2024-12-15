import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/watchlist_provider.dart';
import '../models/stock.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final watchlistProvider = Provider.of<WatchlistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Watchlist"),
      ),
      body: watchlistProvider.watchlist.isEmpty
          ? const Center(
              child: Text(
                "Your watchlist is empty.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: watchlistProvider.watchlist.length,
              itemBuilder: (context, index) {
                final stock = watchlistProvider.watchlist[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(stock.symbol ?? "Unknown Symbol"),
                    subtitle: Text(
                      "Price: \$${stock.currentPrice?.toStringAsFixed(2) ?? 'N/A'}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        watchlistProvider.removeStock(stock);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${stock.symbol} removed from watchlist")),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
