import 'dart:io';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  static Future<dynamic> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        if (kIsWeb) {
          // On web, return XFile directly
          return image;
        } else {
          // On mobile/desktop, return File
          return File(image.path);
        }
      }
      return null;
    } catch (e) {
      developer.log('Error picking image from gallery: $e');
      return null;
    }
  }

  // Pick image from camera
  static Future<dynamic> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        if (kIsWeb) {
          // On web, return XFile directly
          return image;
        } else {
          // On mobile/desktop, return File
          return File(image.path);
        }
      }
      return null;
    } catch (e) {
      developer.log('Error picking image from camera: $e');
      return null;
    }
  }

  // Show image picker options
  static Future<dynamic> showImagePickerOptions(
      {required Function() onGallery, required Function() onCamera}) async {
    dynamic selectedImage;

    await showImagePickerDialog(
      onGallery: () async {
        selectedImage = await pickImageFromGallery();
        onGallery();
      },
      onCamera: () async {
        selectedImage = await pickImageFromCamera();
        onCamera();
      },
    );

    return selectedImage;
  }

  // Show dialog with image picker options
  static Future<void> showImagePickerDialog({
    required Function() onGallery,
    required Function() onCamera,
  }) async {
    // This is a placeholder - actual implementation would be in the widget
    // that calls this method
  }
}
