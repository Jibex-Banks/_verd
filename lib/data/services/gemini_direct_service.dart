import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';

/// Service to handle direct communication with Google's Gemini API
/// bypassing the Firebase Extension for faster, more reliable analysis.
class GeminiDirectService {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiDirectService({required this.apiKey}) {
    // using gemini-2.5-flash as it is the fastest, most cost-effective and latest multimodal model
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  /// Sends the image to Gemini and asks for a strict JSON response
  /// describing the crop's health, diseases, and treatments.
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      // The exact prompt we were using in the Firebase Extension
      final prompt = '''
Act as a Lead Agronomist and Expert Phytopathologist. Your task is to analyze the provided crop image for the AgriScan-AI diagnostic system. 

You must adopt a methodical diagnostic reasoning process: First, carefully observe and document the visual signs (e.g., chlorotic halos, necrotic lesions, fungal hyphae). Second, use these signs to identify the specific crop type and any underlying diseases. Finally, recommend actionable mitigation protocols.

MANDATE: You must return your analysis STRICTLY as a valid, parsable JSON object. Do not include any Markdown formatting, conversational filler, or code block delimiters (e.g., do not output ```json).

Adhere exactly to the following JSON schema:
{
  "cropType": "String (The identified plant species, e.g., Maize, Cassava, Tomato)",
  "healthStatus": "String (Must be exactly one of: Healthy, Warning, Critical)",
  "confidence": "Float (A value between 0.0 and 1.0 representing your diagnostic certainty)",
  "visualSigns": "String (Detailed description of the botanical symptoms observed)",
  "diseases": [
    {
      "name": "String (Scientific or common name of the detected pathogen/disease)",
      "severity": "String (Must be one of: Low, Medium, High)",
      "treatment": "String (Specific agronomic mitigation protocol)"
    }
  ],
  "actionSteps": [
    "String (Immediate action step 1)",
    "String (Immediate action step 2)"
  ]
}
''';

      // Dynamically determine the MIME type
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      debugPrint('[GeminiDirectService] Detected mime type: $mimeType');

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, bytes),
        ])
      ];

      debugPrint('[GeminiDirectService] Sending request to Gemini API...');
      final response = await _model.generateContent(content);
      
      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Received empty response from Gemini API.');
      }

      debugPrint('[GeminiDirectService] Received response. Parsing JSON...');
      return _parseJsonFromMarkdown(text);
      
    } catch (e) {
      debugPrint('[GeminiDirectService] Error in direct analysis: $e');
      rethrow;
    }
  }

  /// Helper to extract JSON if Gemini wraps it in markdown blocks (```json ... ```)
  Map<String, dynamic> _parseJsonFromMarkdown(String text) {
    String cleanText = text.trim();
    if (cleanText.startsWith('```json')) {
      cleanText = cleanText.substring(7);
    } else if (cleanText.startsWith('```')) {
      cleanText = cleanText.substring(3);
    }
    
    if (cleanText.endsWith('```')) {
      cleanText = cleanText.substring(0, cleanText.length - 3);
    }
    
    try {
      return jsonDecode(cleanText.trim()) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[GeminiDirectService] Failed to parse JSON: $e\nRaw text: $text');
      throw Exception('Gemini returned invalid JSON format.');
    }
  }
}
