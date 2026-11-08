import 'package:flutter/material.dart';

class ContentRemovalPage extends StatefulWidget {
  const ContentRemovalPage({super.key});

  @override
  State<ContentRemovalPage> createState() => _ContentRemovalPageState();
}

class _ContentRemovalPageState extends State<ContentRemovalPage> {
  final TextEditingController _urlController = TextEditingController();
  final List<Map<String, String>> _tickets = [
    {
      "platform": "Fake Profile Tracking",
      "url": "https://socialmedia.mock/profile/user123_fake",
      "status": "In Progress",
      "date": "June 20, 2026"
    },
    {
      "platform": "Leaked Image Mirror",
      "url": "https://shadywebsite.mock/img/xyz789.jpg",
      "status": "Removed",
      "date": "June 18, 2026"
    }
  ];

  void _submitTicket() {
    String url = _urlController.text.trim();
    if (url.isEmpty) return;

    String platform = "External Link";
    if (url.contains("facebook") || url.contains("fb")) platform = "Facebook Link";
    if (url.contains("instagram") || url.contains("ig")) platform = "Instagram Link";
    if (url.contains("twitter") || url.contains("x.com")) platform = "X/Twitter Link";

    setState(() {
      _tickets.insert(0, {
        "platform": platform,
        "url": url,
        "status": "Submitted",
        "date": "Today"
      });
      _urlController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Emergency takedown request logged into Nexora registry!"),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2533),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Content Removal Center", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Report Unauthorized Content",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Paste the link of fake profiles or leaked items below to request emergency platform takedown actions.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // URL Input Dock
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Paste offending URL here...",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      fillColor: const Color(0xFF2D3748),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _submitTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("TAKE DOWN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text("Active Takedown Requests", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Active Trackers List
            Expanded(
              child: ListView.builder(
                itemCount: _tickets.length,
                itemBuilder: (context, index) {
                  final item = _tickets[index];
                  bool isRemoved = item["status"] == "Removed";
                  bool isInProgress = item["status"] == "In Progress";

                  return Card(
                    color: const Color(0xFF2D3748),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item["platform"]!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isRemoved
                                      ? Colors.green.withOpacity(0.2)
                                      : (isInProgress ? Colors.orange.withOpacity(0.2) : Colors.blue.withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item["status"]!,
                                  style: TextStyle(
                                    color: isRemoved
                                        ? Colors.greenAccent
                                        : (isInProgress ? Colors.orangeAccent : Colors.blueAccent),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(item["url"]!, style: const TextStyle(color: Colors.white60, fontSize: 12, overflow: TextOverflow.ellipsis)),
                          const Divider(color: Colors.white10, height: 16),
                          Text("Logged: ${item["date"]}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
}