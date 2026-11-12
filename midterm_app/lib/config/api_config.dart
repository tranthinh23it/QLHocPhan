import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConfig {
  /// Tự động chọn baseUrl phù hợp theo platform:
  /// - Web           → localhost (chạy cùng máy với browser)
  /// - Android Emulator → 10.0.2.2 (alias trỏ về máy host)
  /// - iOS Simulator → localhost
  /// - Thiết bị thật → IP LAN của máy tính
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else if (Platform.isAndroid) {
      // Real device: sử dụng IP LAN
      return 'http://192.168.51.103:5000/api';
    } else {
      return 'http://localhost:5000/api'; // iOS Simulator
    }
  }

  static String get debugInfo {
    final platform = kIsWeb ? 'Web' : Platform.operatingSystem;
    return 'Platform: $platform, BaseURL: $baseUrl';
  }
}
