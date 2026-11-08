import 'package:flutter/material.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final List<Map<String, String>> _incomingAlerts = [
    {
      "user": "User_Alpha",
      "type": "SOS TRIGGERED",
      "time": "Just Now",
      "status": "CRITICAL",
      "location": "Lat: 13.3409, Lon: 74.7421"
    },
    {
      "user": "User_Beta",
      "type": "Geofence Boundary Breach",
      "time": "4 mins ago",
      "status": "WARNING",
      "location": "Outside Campus Perimeter"
    },
    {
      "user": "User_Gamma",
      "type": "Anonymous Chat Help Request",
      "time": "12 mins ago",
      "status": "RESOLVED",
      "location": "Route A Corridor"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Sleek obsidian/dark blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 2,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.redAccent),
            SizedBox(width: 10),
            Text("Nexora HQ • Control Panel", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Refreshing live telemetry feeds..."), backgroundColor: Colors.blueAccent),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Analytics Row Summary Cards
            Row(
              children: [
                _buildStatCard("ACTIVE USERS", "142", Colors.blueAccent),
                const SizedBox(width: 12),
                _buildStatCard("LIVE ALERTS", "2 Active", Colors.redAccent),
              ],
            ),
            const SizedBox(height: 25),

            const Text(
              "Live Incoming Dispatch Emergency Queue",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Live Alerts Stream
            Expanded(
              child: ListView.builder(
                itemCount: _incomingAlerts.length,
                itemBuilder: (context, index) {
                  final alert = _incomingAlerts[index];
                  bool isCritical = alert["status"] == "CRITICAL";
                  bool isWarning = alert["status"] == "WARNING";

                  return Card(
                    color: const Color(0xFF1E293B),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isCritical ? Colors.redAccent.withOpacity(0.5) : (isWarning ? Colors.orangeAccent.withOpacity(0.3) : Colors.transparent),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isCritical ? Icons.gpp_bad : (isWarning ? Icons.warning_amber_rounded : Icons.verified_user),
                                    color: isCritical ? Colors.redAccent : (isWarning ? Colors.orangeAccent : Colors.greenAccent),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    alert["type"]!,
                                    style: TextStyle(
                                      color: isCritical ? Colors.redAccent : (isWarning ? Colors.orangeAccent : Colors.greenAccent),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Text(alert["time"]!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          const Divider(color: Colors.white10, height: 20),
                          Text("Target Subject: ${alert["user"]}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text("Telemetry: ${alert["location"]}", style: const TextStyle(color: Colors.white60, fontSize: 13)),
                          const SizedBox(height: 12),

                          // Dispatch Controls Action Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.phone_in_talk, size: 16),
                                label: const Text("Intercept"),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    alert["status"] = "RESOLVED";
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isCritical ? Colors.red : Colors.blueGrey,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(alert["status"] == "RESOLVED" ? "Archived" : "Acknowledge", style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: accentColor, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}