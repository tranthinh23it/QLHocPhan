import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import '../models/giangvien.dart';
import '../config/api_config.dart';

class GiangVienService {
  static String get baseUrl => ApiConfig.baseUrl;

  // Get all GiangVien
  static Future<Map<String, dynamic>> getAllGiangVien() async {
    try {
      final url = Uri.parse('$baseUrl/giangvien');
      developer.log('📤 Fetching giangvien from: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
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
        developer.log('📊 Parsed data: ${data.toString()}');
        final List<dynamic> giangvienList = data['data'] ?? [];
        developer.log('📊 GiangVien list: ${giangvienList.toString()}');
        
        final giangvien = giangvienList.map((u) {
          developer.log('🔍 Mapping item: ${u.toString()}');
          return GiangVien.fromJson(u);
        }).toList();
        
        developer.log('✅ Mapped giangvien: ${giangvien.length} items');
        giangvien.forEach((g) {
          developer.log('👤 GiangVien: idgv=${g.idgv}, fullname=${g.fullname}, sumClass=${g.sumClass}');
        });
        
        return {
          'success': true,
          'data': giangvien,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch giangvien',
          'data': [],
        };
      }
    } catch (e) {
      developer.log('❌ getAllGiangVien exception: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': [],
      };
    }
  }

  // Get GiangVien by ID
  static Future<Map<String, dynamic>> getGiangVienById(String id) async {
    try {
      final url = Uri.parse('$baseUrl/giangvien/$id');
      developer.log('📤 Fetching giangvien: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final giangvien = GiangVien.fromJson(data['data']);
        return {
          'success': true,
          'data': giangvien,
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'GiangVien not found',
        };
      }
    } catch (e) {
      developer.log('❌ getGiangVienById exception: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Create GiangVien with image upload
  static Future<Map<String, dynamic>> createGiangVien({
    required String idgv,
    required String fullname,
    int sumClass = 0,
    dynamic imageFile,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/giangvien');
      developer.log('📤 Creating giangvien at: $url');
      developer.log('📤 Create params - idgv: $idgv, fullname: $fullname, sumClass: $sumClass, hasImage: ${imageFile != null}');
      
      final request = http.MultipartRequest(
        'POST',
        url,
      );

      request.fields['idgv'] = idgv;
      request.fields['fullname'] = fullname;
      request.fields['sumClass'] = sumClass.toString();

      if (imageFile != null) {
        try {
          if (imageFile is XFile) {
            // Handle XFile (web and sometimes mobile)
            developer.log('📤 Processing XFile image');
            final bytes = await imageFile.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(
                'image',
                bytes,
                filename: imageFile.name,
              ),
            );
          } else if (imageFile is File) {
            // Handle File (mobile/desktop)
            developer.log('📤 Processing File image');
            request.files.add(
              await http.MultipartFile.fromPath(
                'image',
                imageFile.path,
              ),
            );
          } else {
            developer.log('⚠️ Unknown image type: ${imageFile.runtimeType}');
          }
        } catch (e) {
          developer.log('❌ Error processing image: $e');
        }
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      developer.log('📥 Response status: ${response.statusCode}');
      developer.log('📥 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final giangvien = GiangVien.fromJson(data['data']);
        return {
          'success': true,
          'data': giangvien,
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to create giangvien',
        };
      }
    } catch (e) {
      developer.log('❌ createGiangVien exception: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Update GiangVien with image upload
  static Future<Map<String, dynamic>> updateGiangVien({
    required String id,
    String? fullname,
    int? sumClass,
    dynamic imageFile,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/giangvien/$id');
      developer.log('📤 Updating giangvien at: $url');
      developer.log('📤 Update params - fullname: $fullname, sumClass: $sumClass, hasImage: ${imageFile != null}');
      
      final request = http.MultipartRequest(
        'PUT',
        url,
      );

      if (fullname != null) {
        request.fields['fullname'] = fullname;
        developer.log('📝 Added field: fullname=$fullname');
      }
      if (sumClass != null) {
        request.fields['sumClass'] = sumClass.toString();
        developer.log('📝 Added field: sumClass=$sumClass');
      }

      if (imageFile != null) {
        try {
          if (imageFile is XFile) {
            // Handle XFile (web and sometimes mobile)
            developer.log('📤 Processing XFile image');
            final bytes = await imageFile.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(
                'image',
                bytes,
                filename: imageFile.name,
              ),
            );
          } else if (imageFile is File) {
            // Handle File (mobile/desktop)
            developer.log('📤 Processing File image');
            request.files.add(
              await http.MultipartFile.fromPath(
                'image',
                imageFile.path,
              ),
            );
          } else {
            developer.log('⚠️ Unknown image type: ${imageFile.runtimeType}');
          }
        } catch (e) {
          developer.log('❌ Error processing image: $e');
        }
      }

      developer.log('📨 Sending request...');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      developer.log('📥 Response status: ${response.statusCode}');
      developer.log('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final giangvien = GiangVien.fromJson(data['data']);
        return {
          'success': true,
          'data': giangvien,
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to update giangvien',
        };
      }
    } catch (e) {
      developer.log('❌ updateGiangVien exception: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Delete GiangVien
  static Future<Map<String, dynamic>> deleteGiangVien(String id) async {
    try {
      final url = Uri.parse('$baseUrl/giangvien/$id');
      developer.log('📤 Deleting giangvien at: $url');
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      developer.log('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to delete giangvien',
        };
      }
    } catch (e) {
      developer.log('❌ deleteGiangVien exception: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
