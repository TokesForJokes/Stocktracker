import 'package:flutter/material.dart';

class StockDetailScreen extends StatelessWidget {
  final Map<String, dynamic> stock;

  const StockDetailScreen({Key? key, required this.stock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          stock['symbol'],
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock Symbol
              Text(
                stock['symbol'],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(height: 8),

              // Stock Name
              Text(
                stock['name'] ?? 'No Name Available',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),

              // Stock Price
              Text(
                "Price: \$${stock['price']?.toStringAsFixed(2) ?? 'N/A'}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // Change
              Text(
                "Change: ${stock['change']?.toString() ?? 'N/A'}%",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: (stock['change'] ?? 0) >= 0
                      ? Colors.greenAccent
                      : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 20),

              const Divider(color: Colors.white70),
              const SizedBox(height: 20),

              // Placeholder for additional details
              const Text(
                "Additional Stock Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "More details like price history, volume, market cap, and graphs can go here.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),

              // Back button for navigation
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text(
                    "Back to Stock List",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
