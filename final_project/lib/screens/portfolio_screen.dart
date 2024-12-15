import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/investment_provider.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvestmentProvider>(context);
    final totalValue = provider.portfolioValue;
    final isGain = provider.portfolioGain >= 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Portfolio Overview', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Portfolio Summary
                  _buildPortfolioSummary(provider),

                  const SizedBox(height: 20),

                  // Investment Distribution Pie Chart
                  _buildPieChart(provider),

                  const SizedBox(height: 20),

                  // Total Gains/Losses
                  _buildMarketSummary(totalValue, provider.portfolioGain, isGain),

                  const SizedBox(height: 20),

                  // Stock List
                  _buildStockList(provider),
                ],
              ),
            ),
    );
  }

  Widget _buildPortfolioSummary(InvestmentProvider provider) {
  // Calculate total portfolio value and gain/loss in real-time
  double totalPurchaseValue = 0.0;
  double totalCurrentValue = 0.0;

  for (var symbol in provider.portfolio.keys) { // Use `portfolio` getter
    final stock = provider.stocks.firstWhere(
      (s) => s['symbol'] == symbol,
      orElse: () => {'price': 0.0},
    );

    final quantity = provider.portfolio[symbol]['quantity'] ?? 0; // Use `portfolio`
    final purchasePrice = provider.portfolio[symbol]['purchasePrice'] ?? 0.0; // Use `portfolio`
    final currentPrice = stock['price'] ?? 0.0;

    totalPurchaseValue += quantity * purchasePrice;
    totalCurrentValue += quantity * currentPrice;
  }

  final gain = totalCurrentValue - totalPurchaseValue;
  final gainPercentage =
      totalPurchaseValue > 0 ? (gain / totalPurchaseValue) * 100 : 0.0;
  final isGain = gain >= 0;

  return Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.grey.shade900,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Portfolio Summary',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Value: \$${totalCurrentValue.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            Text(
              '${isGain ? '+' : ''}${gainPercentage.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isGain ? Colors.greenAccent : Colors.redAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Gain/Loss: ${isGain ? '+' : ''}\$${gain.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            color: isGain ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
      ],
    ),
  );
}



  Widget _buildPieChart(InvestmentProvider provider) {
  Map<String, double> distribution = {};

  for (var stock in provider.stocks) {
    final String symbol = stock['symbol'] ?? 'Unknown';
    final double price = stock['price'] ?? 0.0;
    final int quantity = stock['quantity'] ?? 0;

    if (quantity > 0) {
      // Calculate the value of the stock and add to the distribution map
      distribution[symbol] = price * quantity;
    }
  }

  if (distribution.isEmpty) {
    // Return a placeholder widget if there's no data
    return Container(
      height: 250,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'No data available for distribution',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  return Container(
    height: 250,
    decoration: BoxDecoration(
      color: Colors.grey.shade900,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Investment Distribution",
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: PieChart(
            PieChartData(
              sections: distribution.entries.map((entry) {
                final color = _getRandomColor();
                return PieChartSectionData(
                  value: entry.value,
                  title: entry.key,
                  color: color,
                  radius: 50,
                  titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList(),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
      ],
    ),
  );
}



  Widget _buildMarketSummary(double totalValue, double portfolioGain, bool isGain) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total Market Gain/Loss",
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          Text(
            "${isGain ? '+' : '-'}\$${portfolioGain.abs().toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isGain ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockList(InvestmentProvider provider) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Stocks in Your Portfolio",
        style: TextStyle(fontSize: 18, color: Colors.white70),
      ),
      const SizedBox(height: 12),
      ...provider.stocks.map((stock) {
        final String symbol = stock['symbol'] ?? 'Unknown';
        final double price = stock['price'] ?? 0.0;
        final int quantity = stock['quantity'] ?? 0;
        final double totalStockValue = price * quantity;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRandomColor(),
              child: Text(
                symbol[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              "$symbol ($quantity shares)",
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "Value: \$${totalStockValue.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Text(
              "\$${price.toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.greenAccent),
            ),
          ),
        );
      }).toList(),
    ],
  );
}


  Color _getRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
      1,
    );
  }
}
