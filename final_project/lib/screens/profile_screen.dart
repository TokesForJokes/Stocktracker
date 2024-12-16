import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/investment_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final investmentProvider = Provider.of<InvestmentProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(context),
            const SizedBox(height: 20),
            _buildPortfolioSummary(investmentProvider),
            const SizedBox(height: 20),
            _buildAccountOptions(context),
            const SizedBox(height: 20),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // User Header Section
  Widget _buildUserHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.greenAccent,
            child: Icon(Icons.person, size: 50, color: Colors.black),
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "John Doe", // Replace with dynamic user data
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "john.doe@email.com", // Replace with dynamic user email
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Portfolio Summary Section
  Widget _buildPortfolioSummary(InvestmentProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Portfolio Overview",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPortfolioStat("Total Value", "\$${provider.portfolioValue.toStringAsFixed(2)}"),
              _buildPortfolioStat("Gain/Loss", 
                provider.portfolioGain >= 0 
                  ? "+\$${provider.portfolioGain.toStringAsFixed(2)}" 
                  : "-\$${provider.portfolioGain.abs().toStringAsFixed(2)}",
                provider.portfolioGain >= 0 ? Colors.greenAccent : Colors.redAccent
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioStat(String title, String value, [Color color = Colors.white]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Account Options
  Widget _buildAccountOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Account Settings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          leading: const Icon(Icons.settings, color: Colors.greenAccent),
          title: const Text("Settings", style: TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.info, color: Colors.greenAccent),
          title: const Text("About App", style: TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
          onTap: () {
            _showAboutDialog(context);
          },
        ),
      ],
    );
  }

  // Logout Button
  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          await AuthService().signOut(); // Call sign-out logic
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        ),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          "Logout",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // About Dialog
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "Stock Tracker App",
      applicationVersion: "1.0.0",
      applicationIcon: const Icon(Icons.business, size: 40, color: Colors.greenAccent),
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            "This app helps you track stock investments, view real-time stock prices, and manage your portfolio.",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
