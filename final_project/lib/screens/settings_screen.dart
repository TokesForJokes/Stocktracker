import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings States
  bool notificationsEnabled = true;
  bool darkModeEnabled = true;
  bool biometricLoginEnabled = false;
  bool autoUpdateEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          _buildSectionHeader("General"),
          _buildSwitchTile(
            title: "Enable Notifications",
            subtitle: "Receive alerts for stock updates and news",
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),
          
          
          _buildSwitchTile(
            title: "Auto-Update Prices",
            subtitle: "Refresh stock prices automatically every 60 seconds",
            value: autoUpdateEnabled,
            onChanged: (value) {
              setState(() => autoUpdateEnabled = value);
            },
          ),


          _buildListTile(
            title: "Change Password",
            subtitle: "Update your account password",
            icon: Icons.lock,
            onTap: () {
              _showToast(context, "Change Password - Coming Soon!");
            },
          ),

          const SizedBox(height: 20),
          _buildSectionHeader("Account"),
          _buildListTile(
            title: "Manage Watchlist",
            subtitle: "Customize your favorite stocks",
            icon: Icons.star_border,
            onTap: () {
              _showToast(context, "Manage Watchlist - Coming Soon!");
            },
          ),
          
          const SizedBox(height: 20),
          _buildSectionHeader("About"),
          _buildListTile(
            title: "Version 1.0.0",
            subtitle: "Latest version installed",
            icon: Icons.info_outline,
          ),
          _buildListTile(
            title: "Privacy Policy",
            subtitle: "Learn about our privacy practices",
            icon: Icons.privacy_tip_outlined,
            onTap: () {
              _showToast(context, "Privacy Policy - Coming Soon!");
            },
          ),
          _buildListTile(
            title: "Developer Info",
            subtitle: "Stock Tracker App",
            icon: Icons.developer_mode,
          ),
        ],
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.greenAccent,
        ),
      ),
    );
  }

  // Reusable Switch Tile
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return SwitchListTile(
      activeColor: Colors.greenAccent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      value: value,
      onChanged: onChanged,
    );
  }

  // Reusable List Tile with Icon
  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    void Function()? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.greenAccent),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }

  // Toast Message (Placeholder)
  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade800,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
