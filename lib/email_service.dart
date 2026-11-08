import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class EmailService {
  static const String _serviceId = 'service_k6ki45g';
  static const String _templateId = 'template_107ycck';
  static const String _publicKey = '6o8xsDBmsW-byPrZK';

  static Future<bool> sendSosEmail({
    required String guardianEmail,
    required double lat,
    required double lng,
    required String userName,
  }) async {
    try {
      final String locationLink =
          'https://www.google.com/maps?q=$lat,$lng';

      final String locationText =
          'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';

      final String time = DateTime.now().toString();

      debugPrint('📧 Sending email to: $guardianEmail');

      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'user_name': userName,
            'guardian_email': guardianEmail,
            'location_link': locationLink,
            'location_text': locationText,
            'time': time,
          },
        }),
      );

      debugPrint('📧 Email status: ${response.statusCode}');
      debugPrint('📧 Email response: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Email sent successfully to $guardianEmail');
        return true;
      } else {
        debugPrint('❌ Email failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Email error: $e');
      return false;
    }
  }
}