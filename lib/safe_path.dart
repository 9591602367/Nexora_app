import 'package:flutter/material.dart';

class SafePathPage extends StatelessWidget {
  const SafePathPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2533),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Safe Path Guidance"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_rounded, size: 100, color: Colors.greenAccent.withOpacity(0.8)),
            const SizedBox(height: 20),
            const Text(
              "Map Live Tracking Coming Soon",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                "This feature will plot alternative routes based on crowdsourced safety data and street lighting illumination.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}