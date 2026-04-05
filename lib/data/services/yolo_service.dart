import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

// Prepares image for YOLO: 640x640, float32, normalized 0.0-1.0
Float32List _prepareYoloInputInIsolate(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) throw Exception('Unable to decode image');

  final resized = img.copyResize(image, width: 640, height: 640);
  final inputList = Float32List(1 * 640 * 640 * 3);
  int i = 0;
  for (int y = 0; y < 640; y++) {
    for (int x = 0; x < 640; x++) {
      final p = resized.getPixel(x, y);
      inputList[i++] = p.r.toInt() / 255.0;
      inputList[i++] = p.g.toInt() / 255.0;
      inputList[i++] = p.b.toInt() / 255.0;
    }
  }
  return inputList;
}

Map<String, dynamic>? _cropLeafInIsolate(Map<String, dynamic> args) {
  final bytes = args['bytes'] as Uint8List;
  final box = args['box'] as List<double>; // [x_center, y_center, width, height]
  final destPath = args['destPath'] as String;

  final image = img.decodeImage(bytes);
  if (image == null) return null;

  final originalWidth = image.width;
  final originalHeight = image.height;

  // Box coordinates can be normalized [0-1] or absolute [0-640]
  // We determine this by checking if the width/height are <= 1.0
  final bool isNormalized = box[2] <= 1.0 && box[3] <= 1.0;
  
  final double scaleX = isNormalized ? originalWidth.toDouble() : (originalWidth / 640.0);
  final double scaleY = isNormalized ? originalHeight.toDouble() : (originalHeight / 640.0);

  final double xCenter = box[0] * scaleX;
  final double yCenter = box[1] * scaleY;
  final double boxWidth = box[2] * scaleX;
  final double boxHeight = box[3] * scaleY;

  // Calculate top-left and constraints
  int startX = (xCenter - (boxWidth / 2)).round();
  int startY = (yCenter - (boxHeight / 2)).round();
  int width = boxWidth.round();
  int height = boxHeight.round();

  // Constrain to image bounds
  startX = startX.clamp(0, originalWidth - 1);
  startY = startY.clamp(0, originalHeight - 1);
  width = width.clamp(1, originalWidth - startX);
  height = height.clamp(1, originalHeight - startY);

  final cropped = img.copyCrop(image, x: startX, y: startY, width: width, height: height);
  
  final jpeg = img.encodeJpg(cropped, quality: 90);
  File(destPath).writeAsBytesSync(jpeg);

  return {'path': destPath};
}

class YoloService {
  Interpreter? _interpreter;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> initialize() async {
    if (_isLoaded) return;
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/yolov8n_int8.tflite');
      _isLoaded = true;
      debugPrint('[YoloService] YOLO model loaded successfully.');
    } catch (e) {
      debugPrint('[YoloService] Error initializing YOLO model: $e');
    }
  }

  /// Returns cropped leaf region, or null if no detection
  Future<File?> cropLeaf(File imageFile, {double confThreshold = 0.25}) async {
    if (!_isLoaded) {
      await initialize();
    }
    if (_interpreter == null) return null;

    try {
      final bytes = await imageFile.readAsBytes();
      
      // 1. Resize and normalize to 640x640 float32
      final inputBytes = await compute(_prepareYoloInputInIsolate, bytes);
      final input = inputBytes.buffer.asFloat32List().reshape([1, 640, 640, 3]);

      // 2. Output tensor setup: [1, 300, 6]
      final output = List.generate(1, (_) => List.generate(300, (_) => List.filled(6, 0.0)));

      // 3. Run inference
      _interpreter!.run(input, output);

      // 4. Parse output boxes [1, 300, 6]
      final List<dynamic> boxes = output[0];
      
      List<double> bestBox = [];
      double bestConf = 0.0;

      for (int i = 0; i < 300; i++) {
        final List<double> values = (boxes[i] as List).cast<double>();
        final conf = values[4]; // objectness/confidence
        if (conf > confThreshold && conf > bestConf) {
          bestConf = conf;
          bestBox = values.sublist(0, 4); // [x, y, w, h]
        }
      }

      if (bestBox.isEmpty) {
        debugPrint('[YoloService] No leaf detected above threshold.');
        return null;
      }

      debugPrint('[YoloService] Leaf detected with confidence: $bestConf');

      // 5. Crop original image
      final tempDir = await getTemporaryDirectory();
      final destPath = '${tempDir.path}/cropped_leaf_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final result = await compute(_cropLeafInIsolate, {
        'bytes': bytes,
        'box': bestBox,
        'destPath': destPath,
      });

      if (result != null && result['path'] != null) {
        return File(result['path']);
      }
    } catch (e, stack) {
      debugPrint('[YoloService] YOLO detection failed: $e\n$stack');
    }

    return null;
  }

  void dispose() {
    if (_isLoaded) {
      _interpreter?.close();
    }
  }
}
