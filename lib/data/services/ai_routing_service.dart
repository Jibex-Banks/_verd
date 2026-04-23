import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:verd/data/models/scan_result.dart';
import 'package:verd/data/services/local_ml_service.dart';
import 'package:verd/data/services/storage_service.dart';
import 'package:verd/data/services/firestore_service.dart';
import 'package:verd/data/services/gemini_direct_service.dart';

/// Routes crop scan images intelligently to the correct AI engine.
///
/// If online, it stores the image to trigger the Firebase Gemini Extension.
/// If offline, it routes the image to the local TFLite model.
class AIRoutingService {
  final StorageService _storageService;
  final LocalMLService _localMLService;
  final FirestoreService _firestoreService;
  final GeminiDirectService _geminiService;
  final Connectivity _connectivity = Connectivity();

  AIRoutingService({
    required StorageService storageService,
    required FirestoreService firestoreService,
    required LocalMLService localMLService,
    required GeminiDirectService geminiService,
  }) : _storageService = storageService,
       _firestoreService = firestoreService,
       _localMLService = localMLService,
       _geminiService = geminiService;

  /// Determines device online status, routes the image, and returns the result.
  Future<Map<String, dynamic>> routeScan({
    required String userId,
    required String scanId,
    required File image,
  }) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    final isOnline =
        !connectivityResult.contains(ConnectivityResult.none) &&
        connectivityResult.isNotEmpty;

    if (isOnline) {
      // --- ONLINE PATH (Direct Gemini API) ---
      try {
        // 1. Upload to Storage (we still want to save the image for history)
        final imageUrl = await _storageService.uploadScanImage(
          userId: userId,
          scanId: scanId,
          imageFile: image,
        );

        debugPrint('[AIRoutingService] Hitting Gemini API directly...');
        // 2. Call Gemini Direct Service
        final analysisData = await _geminiService.analyzeImage(image);

        final result = {
          'status': 'success',
          'engine': 'gemini_direct_api',
          'timestamp': DateTime.now().toIso8601String(),
          'imageUrl': imageUrl,
          'localImagePath': image.path,
          'analysis': analysisData,
        };

        // 3. Save the *completed* scan to Firestore for user history
        debugPrint(
          '[AIRoutingService] Analysis complete. Saving to Firestore...',
        );
        final completeScan = ScanResult(
          id: scanId,
          userId: userId,
          imageUrl: imageUrl,
          localImagePath: image.path,
          plantName: analysisData['cropType'] ?? 'Unknown',
          diagnosis: analysisData['healthStatus'] ?? 'Unknown',
          confidence: (analysisData['confidence'] as num?)?.toDouble() ?? 0.0,
          recommendations:
              (analysisData['diseases'] as List<dynamic>?)
                  ?.map((e) => e['treatment'].toString())
                  .toList() ??
              [],
          scannedAt: DateTime.now(),
          synced: true,
          analysisMap: analysisData, // Store the raw map
        );

        await _firestoreService.saveScanRaw(
          userId,
          scanId,
          completeScan.toFirestore(),
        );

        return result;
      } catch (e) {
        debugPrint(
          '[AIRoutingService] Online analysis failed — falling back to local model: $e',
        );

        // Automatic fallback: use local TFLite model
        final localResult = await _localMLService.analyzeCropOffline(image);
        return {
          ...localResult,
          'imageUrl': null, // Upload likely failed or didn't exist
          'localImagePath': image.path,
          'cloudFallback': true,
          'cloudError': e.toString(),
        };
      }
    } else {
      // --- OFFLINE PATH (Local TFLite Model) ---
      final localResult = await _localMLService.analyzeCropOffline(image);
      return {
        ...localResult,
        'localImagePath': image.path,
      };
    }
  }
}
