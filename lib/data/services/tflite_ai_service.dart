import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:verd/data/services/crop_disease_knowledge.dart';
import 'package:verd/data/services/yolo_service.dart';

// Top-level function for Isolate execution to prevent UI stuttering
Uint8List _processImageInIsolate(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) throw Exception('Unable to decode image data');

  final resized = img.copyResize(image, width: 224, height: 224);
  final inputBytes = Uint8List(1 * 224 * 224 * 3);
  int i = 0;

  // Convert to [1, 224, 224, 3] format (normalized 0–255 uint8)
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

/// Result for a single prediction candidate
class PredictionCandidate {
  final String labelKey;
  final double confidence;
  final CropDiseaseKnowledge knowledge;

  PredictionCandidate({
    required this.labelKey,
    required this.confidence,
    required this.knowledge,
  });
}

class TFLiteAIService {
  late Interpreter _interpreter;
  late Map<int, String> _labels;
  final YoloService _yoloService = YoloService();
  bool _isLoaded = false;

  /// Confidence threshold below which we flag the result as uncertain
  static const double uncertaintyThreshold = 0.60;

  bool get isLoaded => _isLoaded;

  Future<void> initialize() async {
    if (_isLoaded) return;
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/verd.tflite');
      final rawLabels = await rootBundle.loadString('assets/models/labels_v3.json');
      final Map<String, dynamic> decoded = json.decode(rawLabels);
      _labels = decoded.map((k, v) => MapEntry(int.parse(k), v as String));
      _isLoaded = true;
      debugPrint('[TFLiteAIService] Model loaded with ${_labels.length} classes.');
    } catch (e) {
      debugPrint('[TFLiteAIService] Error initializing TFLite model: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    if (!_isLoaded) {
      await initialize();
    }

    try {
      // 1. Input Validation
      if (!imageFile.existsSync()) {
        throw Exception('Image file does not exist.');
      }
      final fileSize = await imageFile.length();
      if (fileSize == 0 || fileSize > 15 * 1024 * 1024) {
        throw Exception('Invalid image file size.');
      }

      // 2. YOLO leaf detection
      File? processingFile = await _yoloService.cropLeaf(imageFile);
      processingFile ??= imageFile; // fallback to full image

      // 3. Offload preprocessing to a background Isolate
      final bytes = await processingFile.readAsBytes();
      final preprocessedBytes = await compute(_processImageInIsolate, bytes);

      final input = preprocessedBytes.reshape([1, 224, 224, 3]);
      final outputSize = _labels.length;
      final output = List.filled(outputSize, 0).reshape([1, outputSize]);

      _interpreter.run(input, output);

      // 3. Get raw output values and apply softmax for proper probabilities
      final rawOutput = List<double>.from(
        output[0].map((e) => (e as num).toDouble()),
      );
      final probabilities = _softmax(rawOutput);

      // 4. Get top-3 predictions sorted by confidence
      final indexedProbs = List.generate(
        probabilities.length,
        (i) => MapEntry(i, probabilities[i]),
      );
      indexedProbs.sort((a, b) => b.value.compareTo(a.value));

      final top3 = indexedProbs.take(3).map((entry) {
        final labelKey = _labels[entry.key] ?? 'unknown';
        return PredictionCandidate(
          labelKey: labelKey,
          confidence: entry.value,
          knowledge: CropDiseaseKnowledge.lookup(labelKey),
        );
      }).toList();

      final topPrediction = top3.first;
      final isUncertain = topPrediction.confidence < uncertaintyThreshold;

      debugPrint('[TFLiteAIService] Top: ${topPrediction.labelKey} '
          '(${(topPrediction.confidence * 100).toStringAsFixed(1)}%), '
          'uncertain: $isUncertain');

      return _formatResult(topPrediction, top3, isUncertain);
    } catch (e, stack) {
      debugPrint('[TFLiteAIService] Inference error: $e');
      Error.throwWithStackTrace(Exception('Failed to analyze image offline: $e'), stack);
    }
  }

  /// Applies softmax to convert raw logits to a probability distribution
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce(math.max);
    final exps = logits.map((x) => math.exp(x - maxLogit)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }

  Map<String, dynamic> _formatResult(
    PredictionCandidate top,
    List<PredictionCandidate> top3,
    bool isUncertain,
  ) {
    final knowledge = top.knowledge;

    return {
      'labelKey': top.labelKey,
      'displayName': knowledge.displayName,
      'cropType': knowledge.cropType,
      'healthStatus': knowledge.healthStatus,
      'confidence': top.confidence,
      'isUncertain': isUncertain,
      'visualSigns': knowledge.visualSigns,
      'treatment': knowledge.treatment,
      'actionSteps': knowledge.actionSteps,
      'requiresManualInspection': knowledge.requiresManualInspection,
      'disclaimer': knowledge.disclaimer,
      'top3': top3.map((c) => {
        'labelKey': c.labelKey,
        'displayName': c.knowledge.displayName,
        'cropType': c.knowledge.cropType,
        'confidence': c.confidence,
        'healthStatus': c.knowledge.healthStatus,
      }).toList(),
    };
  }

  void dispose() {
    if (_isLoaded) {
      _interpreter.close();
    }
  }
}
