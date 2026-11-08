import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'location_service.dart';
import 'notification_service.dart';
import 'email_service.dart';
import 'auth_service.dart';

class SafetyHub {
  SafetyHub._privateConstructor();
  static final SafetyHub instance = SafetyHub._privateConstructor();

  bool _isSosActive = false;
  bool _isShakeDetectionOn = false;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  static const double _shakeThreshold = 15.0;
  static const int _shakeCountRequired = 3;
  static const Duration _shakeWindow = Duration(seconds: 2);

  int _shakeCount = 0;
  DateTime? _firstShakeTime;

  bool get isSosActive => _isSosActive;
  bool get isShakeDetectionOn => _isShakeDetectionOn;

  // ─── INITIALIZE ──────────────────────────────────────────────────────────
  Future<void> initialize() async {
    await NotificationService.initialize();
    debugPrint('✅ SafetyHub initialized.');
  }

  // ─── SHAKE DETECTION ─────────────────────────────────────────────────────
  void startShakeDetection(VoidCallback onShakeTriggered) {
    if (_isShakeDetectionOn) return;
    _isShakeDetectionOn = true;
    _shakeCount = 0;
    _firstShakeTime = null;

    _accelerometerSubscription =
        accelerometerEventStream().listen((AccelerometerEvent event) {
          double magnitude =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
          double netAcceleration = (magnitude - 9.8).abs();

          if (netAcceleration > _shakeThreshold) {
            final now = DateTime.now();

            if (_firstShakeTime == null) {
              _firstShakeTime = now;
              _shakeCount = 1;
            } else {
              if (now.difference(_firstShakeTime!) <= _shakeWindow) {
                _shakeCount++;
                debugPrint('🤳 Shake: $_shakeCount/$_shakeCountRequired');

                if (_shakeCount >= _shakeCountRequired) {
                  _shakeCount = 0;
                  _firstShakeTime = null;
                  onShakeTriggered();
                }
              } else {
                _firstShakeTime = now;
                _shakeCount = 1;
              }
            }
          }
        });

    debugPrint('📳 Shake detection started.');
  }

  void stopShakeDetection() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _isShakeDetectionOn = false;
    _shakeCount = 0;
    _firstShakeTime = null;
    debugPrint('⏹️ Shake detection stopped.');
  }

  // ─── CORE SOS PIPELINE ───────────────────────────────────────────────────
  Future<String> _executeSosPipeline(String triggerMethod) async {
    try {
      // 1. Get GPS location
      final position = await LocationService.getCurrentLocation();
      double lat = position?.latitude ?? 0.0;
      double lng = position?.longitude ?? 0.0;
      bool hasLocation = position != null;

      String locationText = hasLocation
          ? LocationService.formatCoordinates(lat, lng)
          : 'Location unavailable';

      String locationLink = hasLocation
          ? LocationService.buildLocationLink(lat, lng)
          : '';

      // 2. Get user profile
      final userProfile = await AuthService.getCurrentUserProfile();
      final String userName = userProfile?['name'] ?? 'Nexora User';
      final String guardianEmail =
          userProfile?['guardianEmail'] ?? '';
      final String uid = AuthService.getCurrentUid() ?? '';

      debugPrint('👤 User: $userName');
      debugPrint('📧 Guardian Email: $guardianEmail');
      debugPrint('📍 Location: $locationText');
      debugPrint('🔔 Trigger: $triggerMethod');

      // 3. Save to Firestore
      if (uid.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('sos_alerts')
            .add({
          'uid': uid,
          'userName': userName,
          'latitude': lat,
          'longitude': lng,
          'locationLink': locationLink,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'active',
          'triggerMethod': triggerMethod,
        });
        debugPrint('📡 SOS saved to Firestore.');
      }

      // 4. Show local notification
      await NotificationService.showSosNotification(
        locationText: locationText,
      );
      debugPrint('🔔 Notification shown.');

      // 5. AUTO SEND EMAIL to guardian
      if (guardianEmail.isNotEmpty) {
        debugPrint('📤 Sending email to guardian...');
        bool emailSent = await EmailService.sendSosEmail(
          guardianEmail: guardianEmail,
          lat: lat,
          lng: lng,
          userName: userName,
        );
        if (emailSent) {
          debugPrint('✅ Email sent successfully!');
        } else {
          debugPrint('❌ Email failed to send.');
        }
      } else {
        debugPrint('⚠️ Guardian email is empty — no email sent.');
        debugPrint('Fix: Add guardianEmail in Firestore users doc.');
      }

      return hasLocation
          ? '🚨 SOS sent! Guardian notified via email.'
          : '🚨 SOS sent! (Location unavailable)';
    } catch (e) {
      debugPrint('⚠️ SOS pipeline error: $e');
      _isSosActive = false;
      return 'SOS failed. Try again.';
    }
  }

  // ─── MANUAL SOS ──────────────────────────────────────────────────────────
  Future<String> triggerSosAlert() async {
    if (_isSosActive) return 'SOS already active.';
    _isSosActive = true;
    debugPrint('🚨 Manual SOS triggered...');
    return await _executeSosPipeline('manual');
  }

  // ─── SHAKE SOS ───────────────────────────────────────────────────────────
  Future<String> triggerSosFromShake() async {
    if (_isSosActive) return 'SOS already active.';
    _isSosActive = true;
    debugPrint('🤳 Shake SOS triggered...');
    return await _executeSosPipeline('shake');
  }

  // ─── VOICE SOS ───────────────────────────────────────────────────────────
  Future<String> triggerSosFromVoice() async {
    if (_isSosActive) return 'SOS already active.';
    _isSosActive = true;
    debugPrint('🎤 Voice SOS triggered...');
    return await _executeSosPipeline('voice');
  }

  // ─── CLEAR SOS ───────────────────────────────────────────────────────────
  void clearSos() {
    _isSosActive = false;
    debugPrint('✅ SOS cleared.');
  }

  // ─── DISPOSE ─────────────────────────────────────────────────────────────
  void dispose() {
    stopShakeDetection();
  }
}