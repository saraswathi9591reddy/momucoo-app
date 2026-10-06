import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../core/models/models.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import '../widgets/primary_button.dart';
import 'batch2/cbc_parser.dart';
import 'batch2/ocr.dart';

/// Port of frontend/src/pages/CBCAnalysis.jsx. OCR via image_picker + ML Kit.
class CBCAnalysisScreen extends StatefulWidget {
  const CBCAnalysisScreen({super.key, this.ocr = const MlKitOcrService()});
  final OcrService ocr;

  @override
  State<CBCAnalysisScreen> createState() => _CBCAnalysisScreenState();
}

const _fields = [
  ('hb', 'Hemoglobin', 'g/dL'),
  ('rbc', 'RBC', 'million/µL'),
  ('mcv', 'MCV', 'fL'),
  ('mch', 'MCH', 'pg'),
  ('mchc', 'MCHC', 'g/dL'),
  ('hematocrit', 'Hematocrit', '%'),
  ('rdw', 'RDW', '%'),
];

class _CBCAnalysisScreenState extends State<CBCAnalysisScreen> {
  final _ctrl = {for (final f in _fields) f.$1: TextEditingController()};
  String _cbcFileName = '', _scanName = '', _reportStatus = '', _scanStatus = '';
  Map<String, String> _scanData = {};
  bool _reading = false;

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<ImageSource?> _chooseSource() => showModalBottomSheet<ImageSource>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Wrap(children: [
            ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera)),
            ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          ]),
        ),
      );

  Future<void> _readCbcReport() async {
    final src = await _chooseSource();
    if (src == null) return;
    final img = await widget.ocr.pick(src);
    if (!mounted) return;
    setState(() {
      _cbcFileName = img?.name ?? '';
      _reportStatus = '';
      for (final c in _ctrl.values) {
        c.clear();
      }
    });
    if (img == null) {
      setState(() => _reportStatus = 'Upload a JPG or PNG CBC blood report for automatic reading.');
      return;
    }
    setState(() {
      _reading = true;
      _reportStatus = 'Reading the CBC report...';
    });
    try {
      final values = extractCbcValues(await widget.ocr.recognize(img.path));
      if (!mounted) return;
      setState(() {
        values.forEach((k, v) => _ctrl[k]?.text = v);
        _reportStatus = values.isNotEmpty
            ? 'Copied ${values.length} value(s) from the CBC report. Please review and edit them before analyzing.'
            : 'No CBC values found. Upload a blood report containing Hb, RBC, MCV, MCH, MCHC, HCT, and RDW.';
      });
    } catch (_) {
      if (mounted) setState(() => _reportStatus = 'The CBC report could not be read. Upload a clearer image.');
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> _readScanReport() async {
    final src = await _chooseSource();
    if (src == null) return;
    final img = await widget.ocr.pick(src);
    if (!mounted) return;
    setState(() {
      _scanName = img?.name ?? '';
      _scanData = {};
      _scanStatus = '';
    });
    if (img == null) return;
    setState(() {
      _reading = true;
      _scanStatus = 'Reading the pregnancy scan report...';
    });
    try {
      final values = extractScanValues(await widget.ocr.recognize(img.path));
      if (!mounted) return;
      setState(() {
        _scanData = values;
        _scanStatus = values.isNotEmpty
            ? 'Pregnancy scan measurements recognized.'
            : 'Scan uploaded, but no readable measurements were found. The original scan is still saved.';
      });
    } catch (_) {
      if (mounted) {
        setState(() => _scanStatus = 'Scan uploaded, but its text could not be read. The original scan is still saved.');
      }
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> _analyze() async {
    final week = getGestationalWeek(_scanData['gestationalAge']);
    final s = AppStorage.instance;
    await s.saveCbcData(CbcData({for (final e in _ctrl.entries) e.key: e.value.text}));
    await s.saveScanData(ScanData(
      name: _scanName,
      uploaded: _scanName.isNotEmpty,
      values: Map<String, dynamic>.of(_scanData),
      uploadedAt: DateTime.now().toUtc().toIso8601String(),
    ));
    // Web: `week: gestationalWeek || ""` (0 is falsy).
    await s.savePregnancyData(PregnancyData(week: week == 0 ? '' : week, symptoms: []));
    if (mounted) context.go(Routes.aiAnalysis);
  }

  Widget _upload({
    required Key key,
    required IconData icon,
    required String title,
    String? tag,
    required String text,
    required String name,
    required String status,
    required VoidCallback onTap,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: AppColors.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.w700), children: [
                if (tag != null)
                  TextSpan(
                      text: '  $tag',
                      style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400, color: AppColors.muted)),
              ])),
            ),
          ]),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
              key: key,
              onPressed: _reading ? null : onTap,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Camera or gallery')),
          if (name.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Selected: $name')),
          if (status.isNotEmpty)
            Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(status, style: const TextStyle(color: AppColors.inkSoft, fontWeight: FontWeight.w600))),
        ]),
      );

  @override
  Widget build(BuildContext context) => PageLayout(
        title: 'CBC Report Analysis',
        eyebrow: 'LAB ANALYSIS',
        activePath: Routes.cbcAnalysis,
        description: 'Enter the values from your Complete Blood Count report for a preliminary screening review.',
        children: [
          ContentCard(
            kicker: 'REPORT VALUES',
            title: 'Complete Blood Count',
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Use the units printed on your report.', style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 12),
              for (final f in _fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    key: Key('cbc-${f.$1}'),
                    controller: _ctrl[f.$1],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: f.$2, hintText: 'From CBC report', suffixText: f.$3),
                  ),
                ),
              _upload(
                key: const Key('cbc-upload'),
                icon: Icons.description_outlined,
                title: 'CBC Report Upload',
                text: 'Add your blood report if you have a digital copy.',
                name: _cbcFileName,
                status: _reportStatus,
                onTap: _readCbcReport,
              ),
              const SizedBox(height: 12),
              _upload(
                key: const Key('scan-upload'),
                icon: Icons.monitor_heart_outlined,
                title: 'Pregnancy Scan Report',
                tag: 'Optional',
                text: 'Upload an ultrasound or pregnancy scan report when available.',
                name: _scanName,
                status: _scanStatus,
                onTap: _readScanReport,
              ),
              const SizedBox(height: 16),
              PrimaryButton(label: 'Analyze My CBC →', loading: _reading, onPressed: _analyze),
            ]),
          ),
        ],
      );
}
