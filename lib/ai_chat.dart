import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;


  final List<Map<String, dynamic>> _messages = [
    {
      "text":
      "Hello! I am Nexora AI Safety Assistant 🛡️\n\nI can help you with:\n• Emergency guidance\n• Self-defense tips\n• Safety awareness\n• Mental health support\n• Legal rights information\n\nHow can I help you stay safe today?",
      "isUser": false,
    },
  ];

  final List<Map<String, dynamic>> _conversationHistory = [];

  Future<void> _sendMessage() async {
    String text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({"text": text, "isUser": true});
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    _conversationHistory.add({
      "role": "user",
      "parts": [{"text": text}]
    });

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "system_instruction": {
            "parts": [
              {
                "text": '''You are Nexora AI Safety Assistant, a helpful and empathetic 
                assistant built into a women safety app called Nexora. 
                Your role is to:
                1. Provide safety guidance and emergency advice
                2. Give self-defense tips and techniques
                3. Offer mental health and emotional support
                4. Explain legal rights for women
                5. Guide users during distress situations
                6. Provide safety awareness tips
                
                Always be:
                - Empathetic and supportive
                - Clear and concise
                - Calm during emergencies
                - Focused on safety
                
                If someone is in immediate danger, always tell them to:
                - Press the SOS button immediately
                - Call 112 (emergency number India)
                - Move to a safe public place
                
                Keep responses short, clear and helpful.
                Respond in the same language the user uses.'''
              }
            ]
          },
          "contents": _conversationHistory,
          "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> parts =
        data['candidates'][0]['content']['parts'];

        final String aiResponse = parts
            .map((p) => p['text'] ?? '')
            .join();

        final String? finishReason =
        data['candidates'][0]['finishReason'];
        debugPrint('✅ Finish reason: $finishReason');

        _conversationHistory.add({
          "role": "model",
          "parts": [{"text": aiResponse}]
        });

        if (mounted) {
          setState(() {
            _messages.add({"text": aiResponse, "isUser": false});
            _isLoading = false;
          });
          _scrollToBottom();
        }
      } else {
        debugPrint('Gemini error: ${response.body}');
        _addErrorMessage();
      }
    } catch (e) {
      debugPrint('AI Chat error: $e');
      _addErrorMessage();
    }
  }

  void _addErrorMessage() {
    if (mounted) {
      setState(() {
        _messages.add({
          "text":
          "I'm having trouble connecting right now. If you're in danger, please press the SOS button immediately or call 112.",
          "isUser": false,
        });
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  final List<String> _suggestions = [
    "I feel unsafe 😰",
    "Self defense tips",
    "Emergency numbers",
    "I need help",
    "Safety tips for night",
    "What are my rights?",
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2533),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 1,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.smart_toy_outlined,
                  color: Colors.white, size: 20),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nexora AI Assistant",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  "Powered by Gemini AI",
                  style: TextStyle(fontSize: 11, color: Colors.greenAccent),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D3748),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Nexora AI is thinking...",
                            style: TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final msg = _messages[index];
                final bool isUser = msg["isUser"] as bool;

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Colors.blueAccent
                          : const Color(0xFF2D3748),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                    ),
                    child: Text(
                      msg["text"].toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_messages.length <= 2)
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _messageController.text = _suggestions[index];
                      _sendMessage();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
                      ),
                      child: Text(
                        _suggestions[index],
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Ask me anything about safety...",
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontSize: 14),
                      fillColor: const Color(0xFF2D3748),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                  _isLoading ? Colors.grey : Colors.blueAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}