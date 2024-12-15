import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/investment_provider.dart';
import '../providers/news_provider.dart';
import 'portfolio_screen.dart';
import 'stock_list_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'stock_detail_screen.dart';
import 'news_webview.dart';

class HomeScreen extends StatefulWidget {
  final String firstName;
  final String lastName;

  const HomeScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final investmentProvider = Provider.of<InvestmentProvider>(context, listen: false);

      // Initial fetch
      investmentProvider.fetchPortfolioData();

      // Update portfolio data every 60 seconds
      _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
        investmentProvider.fetchPortfolioData();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up timer
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0: // Stay on Home
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => PortfolioScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StockListScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 20),
            _buildPortfolioSummary(),
            const SizedBox(height: 20),
            _buildRealTimeStockGraph(),
            const SizedBox(height: 20),
            _buildStockList(),
            const SizedBox(height: 20),
            _buildNewsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Feeling lucky?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.greenAccent),
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              'Welcome, ${widget.firstName} ${widget.lastName}!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioSummary() {
    return Consumer<InvestmentProvider>(
      builder: (context, provider, _) {
         bool isGain = provider.portfolioGain >= 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Portfolio Summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Value: \$${provider.portfolioValue.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, color: Colors.white)),
                  Text(
                    isGain ? '+${provider.portfolioGain.toStringAsFixed(2)}%' : '${provider.portfolioGain.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isGain ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRealTimeStockGraph() {
    return Consumer<InvestmentProvider>(
      builder: (context, provider, _) {
        final spots = provider.realTimeGraphSpots('AAPL');

        if (spots.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        bool isGain = spots.last.y >= spots.first.y;

        return SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 2,
                  color: isGain ? Colors.greenAccent : Colors.redAccent,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: isGain
                          ? [Colors.green.withOpacity(0.4), Colors.black]
                          : [Colors.red.withOpacity(0.4), Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStockList() {
    return Consumer<InvestmentProvider>(
      builder: (context, provider, _) {
        if (provider.stocks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: provider.stocks.take(5).map((stock) {
            final String symbol = stock['symbol'] ?? 'Unknown';
            final double gain = stock['gain'] ?? 0;
            final bool isGain = gain >= 0;

            return ListTile(
              title: Text(
                symbol,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              trailing: Text(
                isGain ? '+${gain.toStringAsFixed(2)}' : gain.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isGain ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StockDetailScreen(stock: stock),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildNewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Consumer<NewsProvider>(
        builder: (context, newsProvider, _) {
          if (newsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (newsProvider.articles.isEmpty) {
            return const Center(
              child: Text(
                "No news available at the moment.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: newsProvider.articles.length,
              itemBuilder: (context, index) {
                final news = newsProvider.articles[index];
                final imageUrl = news['imageUrl'];
                final newsUrl = news['newsUrl'];

                return GestureDetector(
                  onTap: () {
                    if (Uri.parse(newsUrl).host.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NewsWebView(url: newsUrl),
                        ),
                      );
                    } else {
                      debugPrint("Invalid News URL: $newsUrl");
                    }
                  },
                  child: Card(
                    color: Colors.grey.shade900,
                    margin: const EdgeInsets.only(right: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: SizedBox(
                      width: 220,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      height: 100,
                                      color: Colors.grey,
                                      child: const Center(
                                        child: Icon(Icons.broken_image, color: Colors.white),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 100,
                                    color: Colors.grey,
                                    child: const Center(
                                      child: Icon(Icons.broken_image, color: Colors.white),
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              news['title'] ?? 'No Title',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.greenAccent,
      unselectedItemColor: Colors.grey.shade500,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Portfolio'),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Stocks'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
      ],
    );
  }
}
