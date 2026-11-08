import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_page.dart';

// Guardian dashboard — will be fully built in Step 6
// For now it routes correctly so login doesn't crash
class GuardianDashboardPage extends StatelessWidget {
  const GuardianDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2533),
      appBar: AppBar(
        title: const Text("Guardian Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 80, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text(
              "Guardian Dashboard",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "Live alerts and location tracking\nwill appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}