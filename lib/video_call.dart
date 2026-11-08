import 'dart:async';
import 'package:flutter/material.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({super.key});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  bool _isMuted = false;
  int _secondsElapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Pure dark backdrop
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Simulated Fullscreen Video Feed (Incoming Dispatcher/Guardian view)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF1E293B),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 120, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    "Connecting with Nexora Dispatch...",
                    style: TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            // 2. Telemetry Overlay Header
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 4, backgroundColor: Colors.white),
                        const SizedBox(width: 6),
                        const Text("LIVE STREAM", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text(_formatDuration(_secondsElapsed), style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Icon(Icons.gps_fixed, color: Colors.greenAccent, size: 14),
                        SizedBox(width: 4),
                        Text("GPS: Active", style: TextStyle(color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // 3. User's Picture-in-Picture Mini Camera Preview Box
            Positioned(
              right: 20,
              bottom: 120,
              width: 110,
              height: 160,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 1.5),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                ),
                child: const Center(
                  child: Icon(Icons.videocam, color: Colors.white38, size: 30),
                ),
              ),
            ),

            // 4. In-Call Interactive Control Dock
            Positioned(
              bottom: 30,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute Button
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: _isMuted ? Colors.white : Colors.white12,
                    child: IconButton(
                      icon: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: _isMuted ? Colors.black : Colors.white),
                      onPressed: () {
                        setState(() {
                          _isMuted = !_isMuted;
                        });
                      },
                    ),
                  ),

                  // End Call Button
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.call_end, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  // Camera Switch Loop Mock
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white12,
                    child: IconButton(
                      icon: const Icon(Icons.switch_video, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}