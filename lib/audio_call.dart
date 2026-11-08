import 'dart:async';
import 'package:flutter/material.dart';

class AudioCallPage extends StatefulWidget {
  const AudioCallPage({super.key});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
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
      backgroundColor: const Color(0xFF1B2533),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 1. Caller Info Header
            Column(
              children: [
                const Text(
                  "SECURE EMERGENCY LINE",
                  style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Nexora Safety Hub",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(_secondsElapsed),
                  style: const TextStyle(color: Colors.grey, fontSize: 18, fontFamily: 'monospace'),
                ),
              ],
            ),

            // 2. Audio Wave Simulation Visualizer
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent.withOpacity(0.05),
                    ),
                  ),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent.withOpacity(0.1),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF2D3748),
                    child: Icon(Icons.shield, size: 40, color: Colors.blueAccent),
                  ),
                ],
              ),
            ),

            // 3. Status Toast Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, color: Colors.greenAccent, size: 14),
                  SizedBox(width: 8),
                  Text("Encrypted & VoIP Routed", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),

            // 4. In-Call Audio Controls Layout Grid
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute Dial Button
                    _buildControlButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      label: "Mute",
                      isActive: _isMuted,
                      onTap: () {
                        setState(() {
                          _isMuted = !_isMuted;
                        });
                      },
                    ),

                    // Speakerphone Toggle Button
                    _buildControlButton(
                      icon: Icons.volume_up,
                      label: "Speaker",
                      isActive: _isSpeakerOn,
                      onTap: () {
                        setState(() {
                          _isSpeakerOn = !_isSpeakerOn;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // End Call Red Floating Action Button
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required String label, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isActive ? Colors.white : const Color(0xFF2D3748),
            child: Icon(icon, color: isActive ? Colors.black : Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}