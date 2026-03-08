import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:verd/data/services/tflite_ai_service.dart';

/// Routes offline requests to the Local TFLite model.
class LocalMLService {
  final TFLiteAIService _tfliteService;

  LocalMLService({required TFLiteAIService tfliteService}) : _tfliteService = tfliteService;

  /// Analyzes a crop image locally (offline).
  /// 
  /// Returns a JSON-like map containing the structured analysis results.
  Future<Map<String, dynamic>> analyzeCropOffline(File image) async {
    // Enforce API 26 minimum for TFLite offline inference
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt < 26) {
        throw Exception('Offline AI scanning requires Android 8.0+. Please connect to WiFi/Data to use Cloud AI instead.');
      }
    }

    final result = await _tfliteService.analyzeImage(image);
    
    String cropType = 'Unknown';
    if (result['disease'] != null) {
        cropType = result['disease'].split(' ').first;
    }

    return {
      'status': 'success',
      'engine': 'local_tflite',
      'timestamp': DateTime.now().toIso8601String(),
      'analysis': {
        'cropType': cropType,
        'healthStatus': result['status'],
        'confidence': (result['confidence'] as int).toDouble() / 100.0,
        'diseases': result['status'] == 'Healthy' ? [] : [
          {
            'name': result['disease'] ?? 'Unknown Issue',
            'severity': result['status'],
            'treatment': result['treatment']
          }
        ]
      }
    };
  }
}
