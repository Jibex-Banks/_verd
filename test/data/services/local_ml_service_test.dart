import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:verd/data/services/local_ml_service.dart';
import 'package:verd/data/services/tflite_ai_service.dart';

// Generate MockTFLiteAIService
@GenerateNiceMocks([MockSpec<TFLiteAIService>()])
import 'local_ml_service_test.mocks.dart';

void main() {
  late LocalMLService localMLService;
  late MockTFLiteAIService mockTFLiteService;
  
  setUp(() {
    mockTFLiteService = MockTFLiteAIService();
    localMLService = LocalMLService(tfliteService: mockTFLiteService);
  });

  group('LocalMLService.analyzeCropOffline()', () {
    test('Should return correctly formatted healthy crop analysis', () async {
      // Arrange
      final dummyFile = File('dummy.jpg');
      when(mockTFLiteService.analyzeImage(any)).thenAnswer(
        (_) async => {
          'status': 'Healthy',
          'confidence': 98,
          'disease': null,
          'treatment': 'Consistent watering and monitoring recommended.',
          'analyzedVia': 'Local AI (TFLite)',
        },
      );

      // Act
      final result = await localMLService.analyzeCropOffline(dummyFile);

      // Assert
      expect(result['status'], 'success');
      expect(result['engine'], 'local_tflite');
      expect(result['analysis']['healthStatus'], 'Healthy');
      expect(result['analysis']['cropType'], 'Unknown');
      expect(result['analysis']['diseases'], isEmpty);
      expect(result['analysis']['confidence'], 0.98);
    });

    test('Should return correctly formatted diseased crop analysis', () async {
      // Arrange
      final dummyFile = File('dummy2.jpg');
      when(mockTFLiteService.analyzeImage(any)).thenAnswer(
        (_) async => {
          'status': 'Needs Attention',
          'confidence': 85,
          'disease': 'Tomato Early Blight',
          'treatment': 'Apply appropriate fungicide.',
          'analyzedVia': 'Local AI (TFLite)',
        },
      );

      // Act
      final result = await localMLService.analyzeCropOffline(dummyFile);

      // Assert
      expect(result['status'], 'success');
      expect(result['analysis']['healthStatus'], 'Needs Attention');
      expect(result['analysis']['cropType'], 'Tomato'); // Extracts first word from disease name
      expect(result['analysis']['diseases'], isNotEmpty);
      expect(result['analysis']['diseases'][0]['name'], 'Tomato Early Blight');
      expect(result['analysis']['diseases'][0]['severity'], 'Needs Attention');
      expect(result['analysis']['diseases'][0]['treatment'], 'Apply appropriate fungicide.');
      expect(result['analysis']['confidence'], 0.85);
    });
  });
}
