import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verd/data/services/ai_service.dart';
import 'package:verd/data/services/ai_routing_service.dart';
import 'package:verd/data/services/local_ml_service.dart';
import 'package:verd/providers/auth_provider.dart'; // To get firestore/storage providers

import 'package:verd/data/services/tflite_ai_service.dart';

// AI service provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(
    firestoreService: ref.watch(firestoreServiceProvider),
    aiRoutingService: ref.watch(aiRoutingServiceProvider),
  );
});

final tfliteAIServiceProvider = Provider<TFLiteAIService>((ref) {
  return TFLiteAIService();
});

final localMLServiceProvider = Provider<LocalMLService>((ref) {
  return LocalMLService(tfliteService: ref.watch(tfliteAIServiceProvider));
});

final aiRoutingServiceProvider = Provider<AIRoutingService>((ref) {
  return AIRoutingService(
    storageService: ref.watch(storageServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
    localMLService: ref.watch(localMLServiceProvider),
  );
});
