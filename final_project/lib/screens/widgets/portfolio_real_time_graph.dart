import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fl_chart/fl_chart.dart';

class LiveStockGraph extends StatefulWidget {
  final String ticker; // Stock ticker to display

  const LiveStockGraph({required this.ticker, Key? key}) : super(key: key);

  @override
  _LiveStockGraphState createState() => _LiveStockGraphState();
}

class _LiveStockGraphState extends State<LiveStockGraph> {
  late WebSocketChannel _channel;
  final List<FlSpot> _dataPoints = []; // Stores graph data points
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  // Connect to Finnhub WebSocket API
  void _connectWebSocket() {
    const apiKey = 'cteem31r01qt478loe90cteem31r01qt478loe9g'; 
    final url = Uri.parse('wss://ws.finnhub.io?token=$apiKey');
    _channel = WebSocketChannel.connect(url);

    // Subscribe to the ticker
    _channel.sink.add(jsonEncode({'type': 'subscribe', 'symbol': widget.ticker}));
    debugPrint('Subscribed to ${widget.ticker}');

    setState(() {
      _isConnected = true;
    });

    // Listen for real-time updates
    _channel.stream.listen(
      (message) {
        final data = jsonDecode(message);
        if (data['type'] == 'trade') {
          setState(() {
            for (var trade in data['data']) {
              final price = trade['p'] as double;
              final time = DateTime.now().millisecondsSinceEpoch.toDouble();

              // Add new data point
              _dataPoints.add(FlSpot(time, price));

              // Keep only the last 30 data points
              if (_dataPoints.length > 30) {
                _dataPoints.removeAt(0);
              }
            }
          });
        }
      },
      onError: (error) {
        debugPrint('WebSocket Error: $error');
        setState(() {
          _isConnected = false;
        });
      },
      onDone: () {
        debugPrint('WebSocket closed.');
        setState(() {
          _isConnected = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  Widget _buildGraph() {
    if (_dataPoints.isEmpty) {
      return const Center(
        child: Text('Waiting for data...', style: TextStyle(fontSize: 16)),
      );
    }

    // Determine if the graph is gaining or losing
    bool isGain = _dataPoints.last.y >= _dataPoints.first.y;

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: _dataPoints,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Graph: ${widget.ticker}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isConnected
            ? _buildGraph()
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
