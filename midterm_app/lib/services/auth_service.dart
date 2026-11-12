import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import '../config/api_config.dart';

class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;

  // Login function
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');
      developer.log('📤 Sending login request to: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'matkhau': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - backend may not be running');
        },
      );

      developer.log('📥 Response status: ${response.statusCode}');
      developer.log('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      developer.log('❌ Login exception: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Register function with image upload support
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String hoten,
    File? imageFile,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');
      developer.log('📤 Sending register request to: $url');
      
      final request = http.MultipartRequest(
        'POST',
        url,
      );

      request.fields['email'] = email;
      request.fields['matkhau'] = password;
      request.fields['hoten'] = hoten;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'hinhanh',
            imageFile.path,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - backend may not be running');
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);

      developer.log('📥 Response status: ${response.statusCode}');
      developer.log('📥 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      developer.log('❌ Register exception: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
