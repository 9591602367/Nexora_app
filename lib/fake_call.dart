import 'dart:async';
import 'package:flutter/material.dart';

class FakeCallPage extends StatefulWidget {
  const FakeCallPage({super.key});

  @override
  State<FakeCallPage> createState() => _FakeCallPageState();
}

class _FakeCallPageState extends State<FakeCallPage> {
  bool _isCallIncoming = false;
  int _countdown = 5;
  Timer? _timer;

  void _startTimer() {
    setState(() {
      _isCallIncoming = false;
      _countdown = 5;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 1) {
        timer.cancel();
        setState(() {
          _isCallIncoming = true;
        });
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // IF THE COUTDOWN FINISHES, SHOW THE REALISTIC INCOMING CALL SCREEN
    if (_isCallIncoming) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 60.0),
                child: Column(
                  children: [
                    Text(
                      "Mom",
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Nexora Safety Call Incoming...",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.person, size: 70, color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Decline Button
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: "decline",
                          backgroundColor: Colors.red,
                          onPressed: () {
                            setState(() {
                              _isCallIncoming = false;
                            });
                          },
                          child: const Icon(Icons.call_end, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 8),
                        const Text("Decline", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    // Accept Button
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: "accept",
                          backgroundColor: Colors.green,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Mock call connected successfully.")),
                            );
                          },
                          child: const Icon(Icons.call, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 8),
                        const Text("Accept", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // BASE CONFIGURATION SCREEN WITH TIMER BUTTON
    return Scaffold(
      backgroundColor: const Color(0xFF1B2533),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Fake Call Trigger"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_callback_rounded, size: 100, color: Colors.blueAccent.withOpacity(0.8)),
              const SizedBox(height: 20),
              const Text(
                "Trigger Discreet Fake Call",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Use this tool to safely exit uncomfortable social situations or unsafe environments.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.timer, color: Colors.white),
                label: Text(
                  _timer?.isActive == true ? "Triggering in $_countdown..." : "Schedule Call (5s Delay)",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}