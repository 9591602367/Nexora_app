import 'dart:async';
import 'package:flutter/material.dart';

class SosActivationPage extends StatefulWidget {
  const SosActivationPage({super.key});

  @override
  State<SosActivationPage> createState() => _SosActivationPageState();
}

class _SosActivationPageState extends State<SosActivationPage> {
  int _secondsLeft = 5;
  Timer? _timer;
  bool _alertsSent = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
          _alertsSent = true;
        });
      } else {
        setState(() {
          _secondsLeft--;
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Midnight dark background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _alertsSent ? Icons.gpp_maybe_rounded : Icons.warning_amber_rounded,
                size: 100,
                color: _alertsSent ? Colors.redAccent : Colors.orangeAccent,
              ),
              const SizedBox(height: 30),
              Text(
                _alertsSent ? "EMERGENCY ALERTS SENT" : "TRIGGERING SOS ALERTS",
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 16),
              Text(
                _alertsSent
                    ? "Your current location details and distress signals have been dispatched to your emergency contacts."
                    : "Sending distress signals to your guardians automatically in...",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 40),

              // Countdown / Status Display
              if (!_alertsSent)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orangeAccent.withOpacity(0.1),
                    border: Border.all(color: Colors.orangeAccent, width: 2),
                  ),
                  child: Text(
                    "$_secondsLeft",
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                )
              else
                Card(
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.greenAccent),
                        SizedBox(width: 12),
                        Text("GPS Tracking Link Active", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 60),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _alertsSent ? "DISMISS" : "CANCEL (FALSE ALARM)",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}