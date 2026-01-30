import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:geolocator/geolocator.dart';
import 'package:appwrite/appwrite.dart';
import 'appwrite_service.dart';
import 'location_service.dart';

class CameraService {
  CameraService._();
  static final CameraService I = CameraService._();

  final ImagePicker _picker = ImagePicker();

  Future<XFile?> captureGeotaggedPhoto() async {
    try {
      // Request camera permission
      final cameraPermission = await ph.Permission.camera.request();
      if (cameraPermission != ph.PermissionStatus.granted) {
        throw Exception('Camera permission denied. Please grant camera permission.');
      }

      // Take photo
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      return photo;
    } catch (e) {
      print('Error capturing photo: $e');
      rethrow;
    }
  }

  Future<String> uploadPhotoToAppwrite(XFile photo) async {
    try {
      final aw = AppwriteService.I;
      await aw.ensureSession();

      final file = File(photo.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${photo.name}';

      // Create storage client
      final storage = Storage(aw.client);

      // Upload to bucket
      final result = await storage.createFile(
        bucketId: '697b152a002f948d3165',
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path, filename: fileName),
        permissions: [
          Permission.read(Role.any()),
        ],
      );

      // Return the file URL
      return 'https://fra.cloud.appwrite.io/v1/storage/buckets/697b152a002f948d3165/files/${result.$id}/view?project=696a5e940026621a01ee';
    } catch (e) {
      print('Error uploading photo: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> captureGeotaggedPhotoWithLocation() async {
    try {
      // Capture photo first
      final photo = await captureGeotaggedPhoto();
      if (photo == null) {
        throw Exception('No photo captured');
      }

      // Get location
      final position = await LocationService.I.getCurrentLocation();
      if (position == null) {
        throw Exception('Could not get location');
      }

      // Upload photo
      final photoUrl = await uploadPhotoToAppwrite(photo);

      return {
        'photoUrl': photoUrl,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp.toIso8601String(),
      };
    } catch (e) {
      print('Error capturing geotagged photo: $e');
      rethrow;
    }
  }
}