import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SmsService {
  static const String _apiKey =
      'oC2PQyzGIBk9Tb8aN6MhUHRrXnctSi01WpsqwjefAEYDLx3KuvM8h75Sdbn1rYNzwIpPcDUBWJ9T3uQv';

  static Future<bool> sendSosAlert({
    required String guardianPhone,
    required double lat,
    required double lng,
    required String userName,
  }) async {
    try {
      final String locationLink =
          'https://www.google.com/maps?q=$lat,$lng';

      final String message =
          'EMERGENCY ALERT from Nexora! '
          '$userName needs immediate help! '
          'Live Location: $locationLink '
          'Please respond immediately or contact authorities. '
          '- Nexora Safety App';

      String phone = guardianPhone
          .replaceAll('+91', '')
          .replaceAll(' ', '')
          .trim();

      debugPrint('📱 Sending SMS to: $phone');

      final response = await http.post(
        Uri.parse('https://www.fast2sms.com/dev/bulkV2'),
        headers: {
          'authorization': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'route': 'v3',
          'sender_id': 'FSTSMS',
          'message': message,
          'language': 'english',
          'flash': 0,
          'numbers': phone,
        }),
      );

      debugPrint('📡 Status: ${response.statusCode}');
      debugPrint('📡 Response: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          responseData['return'] == true) {
        debugPrint('✅ SMS sent to $phone');
        return true;
      } else {
        debugPrint('❌ SMS failed: $responseData');
        return false;
      }
    } catch (e) {
      debugPrint('❌ SMS error: $e');
      return false;
    }
  }
}