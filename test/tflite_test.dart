import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  test('Inspect TFLite model', () {
    try {
      final interpreter = Interpreter.fromFile('assets/models/model.tflite');
      final inputTensor = interpreter.getInputTensor(0);
      print('=== Input Tensor ===');
      print('Name: ${inputTensor.name}');
      print('Shape: ${inputTensor.shape}');
      print('Type: ${inputTensor.type}');

      final outputTensor = interpreter.getOutputTensor(0);
      print('=== Output Tensor ===');
      print('Name: ${outputTensor.name}');
      print('Shape: ${outputTensor.shape}');
      print('Type: ${outputTensor.type}');
    } catch (e) {
      print('Error loading model: $e');
    }
  });
}
