import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteAIService {
  late Interpreter _interpreter;
  late Map<int, String> _labels;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> initialize() async {
    if (_isLoaded) return;
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/verd_v2.tflite');
      final rawLabels = await rootBundle.loadString('assets/models/verd_v2_labels.json');
      final Map<String, dynamic> decoded = json.decode(rawLabels);
      _labels = decoded.map((k, v) => MapEntry(int.parse(k), v as String));
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error initializing TFLite model: $e');
    }
  }

  Uint8List _preprocessImage(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Unable to decode image');

    final resized = img.copyResize(image, width: 224, height: 224);
    final inputBytes = Uint8List(1 * 224 * 224 * 3);
    int i = 0;
    
    // Convert to [1, 224, 224, 3] format
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final p = resized.getPixel(x, y);
        inputBytes[i++] = p.r.toInt();
        inputBytes[i++] = p.g.toInt();
        inputBytes[i++] = p.b.toInt();
      }
    }
    return inputBytes;
  }

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    if (!_isLoaded) {
      await initialize();
    }

    try {
      final input = _preprocessImage(imageFile).reshape([1, 224, 224, 3]);
      final output = List.filled(54, 0).reshape([1, 54]);

      _interpreter.run(input, output);
      
      final probs = List<double>.from(output[0].map((e) => (e as num).toDouble() / 255.0)); // Normalize probabilities to 0-1
      
      int topIdx = 0;
      double topScore = 0;
      for (int i = 0; i < probs.length; i++) {
        if (probs[i] > topScore) {
          topScore = probs[i];
          topIdx = i;
        }
      }

      final label = _labels[topIdx] ?? 'unknown';
      return _formatResult(label, topScore);
    } catch (e) {
       debugPrint('TFLite inference error: $e');
       throw Exception('Failed to analyze image offline: $e');
    }
  }

  Map<String, dynamic> _formatResult(String rawLabel, double confidence) {
     // Expected output from the prompt: 
     // healthy -> Healthy
     // unknown -> Unknown
     // Needs Attention / Critical 
     
     // Typical labels look like: "tomato_early_blight", "beans_healthy", etc.
     
     String healthStatus = 'Needs Attention';
     if (rawLabel.toLowerCase().contains('healthy')) {
       healthStatus = 'Healthy';
     } else if (rawLabel.toLowerCase().contains('critical') || rawLabel.toLowerCase().contains('virus') || rawLabel.toLowerCase().contains('blight') || rawLabel.toLowerCase().contains('necrosis')) {
       healthStatus = 'Critical';
     }

     String formattedLabel = rawLabel.replaceAll('_', ' ');
     // capitalize words
     formattedLabel = formattedLabel.split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');

     return {
        'status': healthStatus,
        'confidence': (confidence * 100).round(),
        'disease': healthStatus == 'Healthy' ? null : formattedLabel,
        'treatment': _getFallbackTreatment(rawLabel),
        'analyzedVia': 'Local AI (TFLite)',
     };
  }
  
  String _getFallbackTreatment(String label) {
    if (label.contains('healthy')) return 'Consistent watering and monitoring recommended.';
    if (label.contains('rust')) return 'Apply copper-based fungicide. Remove infected plant parts.';
    if (label.contains('blight')) return 'Improve air circulation. Water at the base, not on leaves. Apply appropriate fungicide.';
    if (label.contains('virus')) return 'Remove and destroy infected plants immediately to prevent spread.';
    if (label.contains('spider_mite')) return 'Use insecticidal soap or neem oil. Increase humidity around plants.';
    return 'Consult local agricultural extension for specific treatments regarding $label.';
  }

  void dispose() {
    if (_isLoaded) {
      _interpreter.close();
    }
  }
}
