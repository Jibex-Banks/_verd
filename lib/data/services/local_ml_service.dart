import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:verd/data/services/tflite_ai_service.dart';

/// Service responsible for routing offline image analysis requests
/// to the local TensorFlow Lite model.
///
/// Formats the raw TFLite output into the standardized JSON structure
/// expected by the rest of the application (matching the Cloud AI response format).
class LocalMLService {
  final TFLiteAIService _tfliteService;

  LocalMLService({required TFLiteAIService tfliteService}) : _tfliteService = tfliteService;

  /// Analyzes a crop [image] file locally using on-device ML.
  /// 
  /// Returns a JSON-like [Map] with:
  /// - Top prediction with crop type, health status, confidence
  /// - Top-3 predictions for the UI
  /// - Visual signs, action steps, and uncertainty flag
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

    final topDiseaseName = result['displayName'] as String? ?? 'Unknown';
    final cropType = result['cropType'] as String? ?? 'Unknown';
    final healthStatus = result['healthStatus'] as String? ?? 'Warning';
    final confidence = (result['confidence'] as double?) ?? 0.0;
    final isUncertain = result['isUncertain'] as bool? ?? false;
    final visualSigns = result['visualSigns'] as String? ?? '';
    final treatment = result['treatment'] as String? ?? '';
    final actionSteps = List<String>.from(result['actionSteps'] as List? ?? []);
    final requiresManualInspection = result['requiresManualInspection'] as bool? ?? false;
    final disclaimer = result['disclaimer'] as String?;
    final top3 = result['top3'] as List<dynamic>? ?? [];

    // Build the disease entry (empty if healthy)
    final isHealthy = healthStatus == 'Healthy';
    final List<Map<String, dynamic>> diseases = isHealthy ? [] : [
      {
        'name': topDiseaseName,
        'severity': healthStatus == 'Critical' ? 'Critical' : 'Moderate',
        'treatment': treatment,
        'visualSigns': visualSigns,
        'actionSteps': actionSteps,
      }
    ];

    return {
      'status': 'success',
      'engine': 'local_tflite',
      'timestamp': DateTime.now().toIso8601String(),
      'analysis': {
        'cropType': cropType,
        'healthStatus': healthStatus,
        'confidence': confidence,
        'isUncertain': isUncertain,
        'diseases': diseases,
        // Rich local-only fields for enhanced UI
        'visualSigns': visualSigns,
        'actionSteps': actionSteps,
        'requiresManualInspection': requiresManualInspection,
        'disclaimer': disclaimer,
        'top3': top3,
      }
    };
  }
}
