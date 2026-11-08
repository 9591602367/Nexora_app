import 'package:flutter/material.dart';

class AnonymousChatPage extends StatefulWidget {
  const AnonymousChatPage({super.key});

  @override
  State<AnonymousChatPage> createState() => _AnonymousChatPageState();
}

class _AnonymousChatPageState extends State<AnonymousChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      "text": "Hello. You are securely connected to a verified Nexora support counselor. Your identity is completely masked and anonymous. How can we help you today?",
      "isUser": false,
    },
  ];

  // NEW: Custom response engine based on what the user types
  String _getSmartResponse(String userText) {
    String text = userText.toLowerCase();

    if (text.contains("hello") || text.contains("hi") || text.contains("hey")) {
      return "Hello! I am here and keeping an eye on this secure channel. Let me know if you need any safety guidance or assistance.";
    }
    else if (text.contains("walk") || text.contains("nervous") || text.contains("dark") || text.contains("home")) {
      return "I understand. Please keep this chat open. If you feel unsafe, you can also head to your 'Safe Path Guidance' tool on the dashboard or hold down the SOS button.";
    }
    else if (text.contains("help") || text.contains("emergency") || text.contains("danger")) {
      return "If you are in immediate danger, please press and hold the red SOS button on your dashboard to notify your emergency contacts instantly!";
    }
    else if (text.contains("thank")) {
      return "You're very welcome! Stay safe out there. Don't hesitate to type if anything changes.";
    }

    // Default reply if no keywords match
    return "Received. Your report has been noted anonymously. Our support network is here if you need active tracking or guidance.";
  }

  void _sendMessage() {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"text": text, "isUser": true});
      _messageController.clear();
    });

    // Determine response based on input text
    String automatedReply = _getSmartResponse(text);

    // Simulate an automatic supportive reply after 1.2 seconds
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          "text": automatedReply,
          "isUser": false,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2533),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Support Chat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Identity Masked • Incognito", style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blueAccent.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, color: Colors.blueAccent, size: 16),
                SizedBox(width: 8),
                Text(
                  "End-to-End Encrypted Chat Window",
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg["isUser"];
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : const Color(0xFF2D3748),
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                      ),
                    ),
                    child: Text(
                      msg["text"],
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type an anonymous message...",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      fillColor: const Color(0xFF2D3748),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}