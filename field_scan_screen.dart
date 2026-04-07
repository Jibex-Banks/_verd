// lib/screens/field_scan_screen.dart
//
// Drop this screen into your existing Flutter app.
// pubspec.yaml additions needed:
//   image_picker: ^1.0.7
//   http: ^1.2.0

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/agriscan_service.dart';

class FieldScanScreen extends StatefulWidget {
  const FieldScanScreen({super.key});

  @override
  State<FieldScanScreen> createState() => _FieldScanScreenState();
}

class _FieldScanScreenState extends State<FieldScanScreen> {
  File? _imageFile;
  ScanResult? _result;
  ScanZone? _selectedZone;
  bool _loading = false;
  String? _error;

  // ── Colors ──────────────────────────────────────────────────────────────────

  Color _severityColor(double s) {
    if (s >= 0.75) return const Color(0xFFC62828);
    if (s >= 0.55) return const Color(0xFFE53935);
    if (s >= 0.45) return const Color(0xFFE65100);
    if (s >= 0.30) return const Color(0xFFFF8F00);
    if (s >= 0.20) return const Color(0xFFF9A825);
    if (s >= 0.10) return const Color(0xFFAED581);
    return const Color(0xFF2E7D32);
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _imageFile   = File(picked.path);
      _result      = null;
      _selectedZone = null;
      _error       = null;
    });

    await _runScan();
  }

  Future<void> _runScan() async {
    if (_imageFile == null) return;
    setState(() { _loading = true; _error = null; });

    try {
      final result = await AgriScanService.scanImage(_imageFile!);
      setState(() { _result = result; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        title: const Text('AgriScan — Field Disease Map',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUploadCard(),
                  if (_loading) _buildLoading(),
                  if (_error != null) _buildError(),
                  if (_result != null) ...[
                    const SizedBox(height: 16),
                    _buildSummaryCards(),
                    const SizedBox(height: 16),
                    _buildHeatmapPanel(),
                    if (_selectedZone != null) ...[
                      const SizedBox(height: 16),
                      _buildZoneDetail(_selectedZone!),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Upload card ──────────────────────────────────────────────────────────────

  Widget _buildUploadCard() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: _imageFile == null ? 160 : 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD8E4D8)),
        ),
        child: _imageFile == null
            ? _buildUploadPlaceholder()
            : _buildImagePreview(),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 40, color: Color(0xFF2D6A4F)),
        SizedBox(height: 10),
        Text('Tap to upload drone image',
            style: TextStyle(fontSize: 15, color: Color(0xFF2D6A4F),
                fontWeight: FontWeight.w600)),
        SizedBox(height(4)),
        Text('JPG or PNG from your gallery',
            style: TextStyle(fontSize: 12, color: Color(0xFF5A7A5A))),
      ],
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(_imageFile!, fit: BoxFit.cover),
          Positioned(
            bottom: 8, right: 8,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B4332),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Change', style: TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loading / Error ──────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          CircularProgressIndicator(color: Color(0xFF2D6A4F)),
          SizedBox(height: 12),
          Text('Analyzing field...', style: TextStyle(color: Color(0xFF5A7A5A))),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(_error!, style: const TextStyle(color: Color(0xFFC62828), fontSize: 13)),
    );
  }

  // ── Summary cards ────────────────────────────────────────────────────────────

  Widget _buildSummaryCards() {
    final s = _result!.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Scan ${_result!.scanId}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF5A7A5A),
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(
          children: [
            _metricCard('${s.criticalZones}', 'Critical', const Color(0xFFC62828)),
            const SizedBox(width: 8),
            _metricCard('${s.moderateZones}', 'Moderate', const Color(0xFFE65100)),
            const SizedBox(width: 8),
            _metricCard('${s.lowZones}', 'Low risk', const Color(0xFFF9A825)),
            const SizedBox(width: 8),
            _metricCard('${s.affectedPct}%', 'Affected', const Color(0xFF1B4332)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: s.criticalZones > 4
                ? const Color(0xFFFDE8E8)
                : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(s.recommendedAction,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: s.criticalZones > 4
                      ? const Color(0xFFC62828)
                      : const Color(0xFF1B4332))),
        ),
      ],
    );
  }

  Widget _metricCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD8E4D8)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(
                fontSize: 10, color: Color(0xFF5A7A5A)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── Heatmap ──────────────────────────────────────────────────────────────────

  Widget _buildHeatmapPanel() {
    final r = _result!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E4D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DISEASE INTENSITY MAP',
              style: TextStyle(fontSize: 11, letterSpacing: 0.8,
                  color: Color(0xFF5A7A5A), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Tap a zone to see details',
              style: TextStyle(fontSize: 12, color: Color(0xFF5A7A5A))),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: r.gridCols / r.gridRows,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: r.gridCols,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: r.zones.length,
              itemBuilder: (ctx, i) {
                final zone = r.zones[i];
                final isSelected = _selectedZone?.row == zone.row &&
                    _selectedZone?.col == zone.col;
                return GestureDetector(
                  onTap: () => setState(() => _selectedZone = zone),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: _severityColor(zone.severity),
                      borderRadius: BorderRadius.circular(2),
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Healthy', style: TextStyle(fontSize: 11, color: Color(0xFF5A7A5A))),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(colors: [
                      Color(0xFF2E7D32), Color(0xFFF9A825),
                      Color(0xFFE65100), Color(0xFFC62828),
                    ]),
                  ),
                ),
              ),
              const Text('Critical', style: TextStyle(fontSize: 11, color: Color(0xFF5A7A5A))),
            ],
          ),
        ],
      ),
    );
  }

  // ── Zone detail ──────────────────────────────────────────────────────────────

  Widget _buildZoneDetail(ScanZone zone) {
    final color = _severityColor(zone.severity);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E4D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14, height: 14,
                decoration: BoxDecoration(color: color,
                    borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(width: 8),
              Text(zone.disease, style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: zone.severity,
              minHeight: 6,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Text('${zone.severityLabel.toUpperCase()}  ·  '
              '${(zone.severity * 100).round()}% severity  ·  '
              '${(zone.confidence * 100).round()}% confidence',
              style: const TextStyle(fontSize: 11, color: Color(0xFF5A7A5A))),
          if (zone.disease != 'Healthy') ...[
            const SizedBox(height: 12),
            Text(zone.yieldImpact, style: const TextStyle(
                fontSize: 12, color: Color(0xFFC62828), fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            const Text('RECOMMENDED ACTIONS', style: TextStyle(
                fontSize: 11, letterSpacing: 0.7, color: Color(0xFF5A7A5A),
                fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...zone.treatments.map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('→ ', style: TextStyle(
                      color: Color(0xFF2D6A4F), fontWeight: FontWeight.w600)),
                  Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
                ],
              ),
            )),
          ] else ...[
            const SizedBox(height: 12),
            const Text('✓ This zone is healthy. No action required.',
                style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}
