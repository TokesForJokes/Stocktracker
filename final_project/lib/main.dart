import 'package:final_project/screens/Stock_Detail_Screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';


import 'firebase_options.dart';
import 'providers/watchlist_provider.dart';
import 'providers/news_provider.dart';
import 'providers/investment_provider.dart';


import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/newsfeed_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/stock_search_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase only if it hasn't been initialized yet
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    print("Firebase Initialization Error: $e"); 
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InvestmentProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()..fetchStockNews()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Stock Tracker App',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.greenAccent,
          scaffoldBackgroundColor: Colors.black,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(firstName: 'John', lastName: 'Doe'),
          '/watchlist': (context) => const WatchlistScreen(),
          '/newsfeed': (context) => const NewsFeedScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/search': (context) => const StockSearchScreen(),
          '/detail': (context) => const StockDetailScreen(stock: {}),
          
        },
      ),
    );
  }
}
