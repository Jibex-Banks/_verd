// lib/services/agriscan_service.dart
// Add to pubspec.yaml:
//   http: ^1.2.0

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// ── Change this to your deployed URL ──────────────────────────────────────────
const String kApiBaseUrl = 'http://10.0.2.2:8000'; // Android emulator → localhost
// For a real device on same WiFi: 'http://192.168.x.x:8000'
// For Hugging Face Spaces:        'https://your-space.hf.space'
// ─────────────────────────────────────────────────────────────────────────────

// ── Models ────────────────────────────────────────────────────────────────────

class ScanZone {
  final int row;
  final int col;
  final double severity;
  final String severityLabel;
  final String disease;
  final double confidence;
  final List<String> treatments;
  final String yieldImpact;
  final String spreadNote;

  ScanZone.fromJson(Map<String, dynamic> j)
      : row           = j['row'],
        col           = j['col'],
        severity      = (j['severity'] as num).toDouble(),
        severityLabel = j['severity_label'],
        disease       = j['disease'],
        confidence    = (j['confidence'] as num).toDouble(),
        treatments    = List<String>.from(j['treatments']),
        yieldImpact   = j['yield_impact'],
        spreadNote    = j['spread_note'];
}

class ScanSummary {
  final int criticalZones;
  final int moderateZones;
  final int lowZones;
  final int healthyZones;
  final double affectedPct;
  final List<String> diseasesDetected;
  final String recommendedAction;

  ScanSummary.fromJson(Map<String, dynamic> j)
      : criticalZones     = j['critical_zones'],
        moderateZones     = j['moderate_zones'],
        lowZones          = j['low_zones'],
        healthyZones      = j['healthy_zones'],
        affectedPct       = (j['affected_pct'] as num).toDouble(),
        diseasesDetected  = List<String>.from(j['diseases_detected']),
        recommendedAction = j['recommended_action'];
}

class ScanResult {
  final String scanId;
  final String filename;
  final int imageWidth;
  final int imageHeight;
  final int gridRows;
  final int gridCols;
  final List<ScanZone> zones;
  final ScanSummary summary;

  ScanResult.fromJson(Map<String, dynamic> j)
      : scanId      = j['scan_id'],
        filename    = j['filename'],
        imageWidth  = j['image_width'],
        imageHeight = j['image_height'],
        gridRows    = j['grid_rows'],
        gridCols    = j['grid_cols'],
        zones       = (j['zones'] as List).map((z) => ScanZone.fromJson(z)).toList(),
        summary     = ScanSummary.fromJson(j['summary']);

  ScanZone zoneAt(int row, int col) =>
      zones.firstWhere((z) => z.row == row && z.col == col);
}

// ── Service ───────────────────────────────────────────────────────────────────

class AgriScanService {
  static Future<ScanResult> scanImage(File imageFile) async {
    final uri     = Uri.parse('$kApiBaseUrl/scan');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      // Let the server detect content type
    ));

    final streamed  = await request.send();
    final response  = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return ScanResult.fromJson(jsonDecode(response.body));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['detail'] ?? 'Scan failed: ${response.statusCode}');
    }
  }
}
