import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import 'news_webview.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock News Feed'),
        backgroundColor: Colors.green.shade700,
      ),
      body: newsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: newsProvider.articles.length,
              itemBuilder: (context, index) {
                final news = newsProvider.articles[index];

                return GestureDetector(
                  onTap: () {
                    // Open NewsWebView on card tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsWebView(url: news['newsUrl']),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display image if available
                        news['imageUrl'] != null && news['imageUrl'].isNotEmpty
                            ? Image.network(
                                news['imageUrl'],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 180,
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(Icons.error),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 180,
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            news['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
