import 'package:flutter/material.dart';
import 'safety_hub.dart';
import 'login_page.dart';
import 'auth_service.dart';
import 'safe_path.dart';
import 'geofence_map.dart';
import 'ai_chat.dart';
import 'content_removal.dart';
import 'educational_videos.dart';
import 'fake_call.dart';
import 'anonymous_chat.dart';
import 'video_call.dart';
import 'audio_call.dart';
import 'emotion/emotion_detection_screen.dart'; // ADDED
 
class HomePage extends StatefulWidget {
  const HomePage({super.key});
 
  @override
  State<HomePage> createState() => _HomePageState();
}
 
class _HomePageState extends State<HomePage> {
  bool _isSosTriggered = false;
  bool _isBackgroundServiceActive = false;
  bool _isSosLoading = false;
  String _userName = '';
 
  @override
  void initState() {
    super.initState();
    _initHub();
    _loadUserName();
  }
 
  Future<void> _initHub() async {
    await SafetyHub.instance.initialize();
  }
 
  Future<void> _loadUserName() async {
    final profile = await AuthService.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _userName = profile?['name'] ?? 'User';
      });
    }
  }
 
  // ─── Toggle shake detection with background service switch ─────────────────
  void _toggleBackgroundService(bool value) {
    setState(() => _isBackgroundServiceActive = value);
 
    if (value) {
      SafetyHub.instance.startShakeDetection(() {
        // Called when shake is detected
        _handleShakeSos();
      });
      _showSnack('📳 Shake detection active. Shake vigorously to trigger SOS.',
          Colors.greenAccent);
    } else {
      SafetyHub.instance.stopShakeDetection();
      _showSnack('Shake detection stopped.', Colors.grey);
    }
  }
 
  // ─── Manual SOS (long press) ───────────────────────────────────────────────
  Future<void> _handleLongPressSos() async {
    if (_isSosLoading) return;
 
    setState(() {
      _isSosTriggered = true;
      _isSosLoading = true;
    });
 
    _showSnack('🚨 Sending SOS alert...', Colors.redAccent);
 
    final String result = await SafetyHub.instance.triggerSosAlert();
 
    if (mounted) {
      setState(() {
        _isSosLoading = false;
      });
      _showSnack(result, Colors.redAccent);
    }
  }
 
  // ─── Shake SOS ────────────────────────────────────────────────────────────
  Future<void> _handleShakeSos() async {
    if (_isSosLoading || !mounted) return;
 
    setState(() {
      _isSosTriggered = true;
      _isSosLoading = true;
    });
 
    _showSnack('🤳 Shake detected! Sending SOS...', Colors.orangeAccent);
 
    final String result = await SafetyHub.instance.triggerSosFromShake();
 
    if (mounted) {
      setState(() => _isSosLoading = false);
      _showSnack(result, Colors.orangeAccent);
    }
  }
 
  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }
 
  @override
  void dispose() {
    SafetyHub.instance.stopShakeDetection();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nexora",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 20),
            ),
            Text(
              'Welcome, $_userName',
              style:
              const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            onPressed: () async {
              SafetyHub.instance.stopShakeDetection();
              await AuthService.logout();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Background Service / Shake Detection Toggle ──────────────
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: _isBackgroundServiceActive
                      ? Colors.greenAccent.withOpacity(0.4)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Switch(
                    value: _isBackgroundServiceActive,
                    activeColor: Colors.greenAccent,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.white24,
                    onChanged: _toggleBackgroundService,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isBackgroundServiceActive
                          ? '📳 Shake Detection: Active'
                          : 'Shake Detection: Off',
                      style: TextStyle(
                        color: _isBackgroundServiceActive
                            ? Colors.greenAccent
                            : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
 
            const SizedBox(height: 30),
 
            // ── SOS Button ───────────────────────────────────────────────
            Center(
              child: GestureDetector(
                onLongPress: _handleLongPressSos,
                onLongPressEnd: (_) {
                  setState(() => _isSosTriggered = false);
                  SafetyHub.instance.clearSos();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Container(
                      width: 195,
                      height: 195,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.redAccent.withOpacity(0.2),
                            width: 2),
                      ),
                    ),
                    // Main SOS circle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 155,
                      height: 155,
                      decoration: BoxDecoration(
                        color: _isSosTriggered
                            ? Colors.red.shade900
                            : const Color(0xFFE11D48),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                            const Color(0xFFE11D48).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 6,
                          )
                        ],
                      ),
                      child: Center(
                        child: _isSosLoading
                            ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3)
                            : const Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
 
            const SizedBox(height: 12),
            const Text(
              'Press and hold in emergency situations',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 6),
            const Text(
              'Or shake your phone vigorously 3 times',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
 
            const SizedBox(height: 36),
 
            // ── Section 1: Core Features ─────────────────────────────────
            _sectionLabel('Core Features'),
            const SizedBox(height: 14),
            Row(
              children: [
                _dashboardItem(Icons.gesture, 'Safe Path\nGuidance',
                    Colors.greenAccent, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SafePathPage()));
                    }),
                _dashboardItem(Icons.map_outlined, 'Geofence\nMap',
                    Colors.white70, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const GeofenceMapPage()));
                    }),
                _dashboardItem(Icons.smart_toy_outlined, 'AI Assistant',
                    Colors.white70, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AiChatPage()));
                    }),
              ],
            ),
 
            const SizedBox(height: 28),
 
            // ── Section 2: Proactive Safety ──────────────────────────────
            _sectionLabel('Proactive Safety Tools'),
            const SizedBox(height: 14),
            Row(
              children: [
                _dashboardItem(Icons.gpp_bad_outlined, 'Content\nRemoval',
                    Colors.white70, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ContentRemovalPage()));
                    }),
                _dashboardItem(
                    Icons.play_circle_outline_rounded,
                    'Educational\nVideos',
                    Colors.white70, () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const EducationalVideosPage()));
                }),
                _dashboardItem(Icons.phone_in_talk_outlined, 'Fake Call',
                    Colors.white70, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FakeCallPage()));
                    }),
              ],
            ),
 
            const SizedBox(height: 28),
 
            // ── Section 3: Support ───────────────────────────────────────
            _sectionLabel('Support & Awareness'),
            const SizedBox(height: 14),
            Row(
              children: [
                _dashboardItem(Icons.visibility_off_outlined,
                    'Anonymous\nChat', Colors.white70, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AnonymousChatPage()));
                    }),
                _dashboardItem(Icons.video_call_outlined, 'Video\nCall',
                    Colors.white70, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const VideoCallPage()));
                    }),
                _dashboardItem(Icons.local_phone_outlined, 'Audio\nCall',
                    Colors.white70, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AudioCallPage()));
                    }),
              ],
            ),
 
            // ── Section 4: Wellbeing (ADDED) ─────────────────────────────
            const SizedBox(height: 28),
            _sectionLabel('Wellbeing'),
            const SizedBox(height: 14),
            Row(
              children: [
                _dashboardItem(Icons.mood_outlined, 'Emotion\nDetection',
                    Colors.white70, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EmotionDetectionScreen()));
                    }),
                // Empty slots keep the icon the same size as the rows above.
                const Expanded(child: SizedBox()),
                const Expanded(child: SizedBox()),
              ],
            ),
            // ── end of added section ─────────────────────────────────────
 
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
 
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
 
  Widget _dashboardItem(
      IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
 