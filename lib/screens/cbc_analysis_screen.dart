import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../core/models/models.dart';
import '../core/risk_engine.dart';
import '../core/storage.dart';
import '../core/theme.dart';
import '../router.dart';
import '../widgets/content_card.dart';
import '../widgets/page_layout.dart';
import '../widgets/primary_button.dart';
import 'batch2/cbc_parser.dart';
import 'batch2/ocr.dart';

/// Upgraded CBC Analysis Screen with instant inline Risk Level output matching web app.
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
  RiskResult? _inlineResult;

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
      _inlineResult = null;
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
            ? 'Copied ${values.length} value(s) from report. Review below and tap "Analyze My CBC".'
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
      _inlineResult = null;
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
            : 'Scan uploaded, but no readable measurements were found.';
      });
    } catch (_) {
      if (mounted) {
        setState(() => _scanStatus = 'Scan uploaded, but its text could not be read.');
      }
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> _analyze() async {
    final week = getGestationalWeek(_scanData['gestationalAge']);
    final cbcMap = {for (final e in _ctrl.entries) e.key: e.value.text};
    final s = AppStorage.instance;
    await s.saveCbcData(CbcData(cbcMap));
    await s.saveScanData(ScanData(
      name: _scanName,
      uploaded: _scanName.isNotEmpty,
      values: Map<String, dynamic>.of(_scanData),
      uploadedAt: DateTime.now().toUtc().toIso8601String(),
    ));
    await s.savePregnancyData(PregnancyData(week: week == 0 ? '' : week, symptoms: []));

    // Evaluate risk directly
    final evaluated = RiskEngine.evaluate(
      cbc: cbcMap,
      pregnancy: {'week': week == 0 ? '' : week, 'symptoms': []},
      scan: Map<String, dynamic>.of(_scanData),
    );

    setState(() {
      _inlineResult = evaluated;
    });
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
        title: 'CBC & Pregnancy Analysis',
        eyebrow: 'LAB SCREENING',
        activePath: Routes.cbcAnalysis,
        description: 'Upload your blood report and scan to directly view your preliminary anemia risk level.',
        children: [
          ContentCard(
            kicker: 'REPORT VALUES',
            title: 'Complete Blood Count',
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Enter or review values from your laboratory report. Hb is required.', style: TextStyle(color: AppColors.muted)),
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
                    decoration: InputDecoration(
                      labelText: f.$2,
                      hintText: 'From CBC report',
                      suffixText: f.$3,
                    ),
                  ),
                ),
              _upload(
                key: const Key('cbc-upload'),
                icon: Icons.description_outlined,
                title: 'CBC Report Upload',
                text: 'Add your blood report image for auto-reading.',
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
              PrimaryButton(
                label: '⚡ Analyze & Show Risk Level',
                loading: _reading,
                onPressed: _analyze,
              ),
            ]),
          ),

          // =========================================================================
          // INLINE RISK LEVEL RESULT CARD (MATCHING WEB APP)
          // =========================================================================
          if (_inlineResult != null) ...[
            const SizedBox(height: 16),
            ContentCard(
              kicker: 'SCREENING OUTPUT (WHO 2011)',
              title: 'Anemia Risk Assessment Result',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _inlineResult!.risk == 'Low'
                          ? AppColors.successBg
                          : _inlineResult!.risk == 'Moderate'
                              ? AppColors.peachBg
                              : const Color(0xFFFDE8E8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _inlineResult!.risk == 'Low'
                            ? AppColors.success
                            : _inlineResult!.risk == 'Moderate'
                                ? Colors.orange
                                : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_inlineResult!.risk.toUpperCase()} RISK',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: _inlineResult!.risk == 'Low'
                                      ? AppColors.success
                                      : _inlineResult!.risk == 'Moderate'
                                          ? Colors.orange.shade800
                                          : AppColors.primary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Score: ${_inlineResult!.score}/100',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _inlineResult!.anemiaLikely ? 'Anemia Pattern Detected' : 'No Anemia Detected',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on WHO 2011 pregnancy threshold guidelines (Hb: ${_ctrl['hb']?.text.isNotEmpty == true ? _ctrl['hb']!.text : '--'} g/dL).',
                          style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  // Factors
                  if (_inlineResult!.factors.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text('Identified Indicators:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    for (final f in _inlineResult!.factors)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(f, style: const TextStyle(fontSize: 13, color: AppColors.inkSoft))),
                          ],
                        ),
                      ),
                  ],

                  // Recommendations
                  if (_inlineResult!.recommendations.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text('Clinical Recommendations:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    for (final r in _inlineResult!.recommendations)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(child: Text(r, style: const TextStyle(fontSize: 13, color: AppColors.ink))),
                          ],
                        ),
                      ),
                  ],

                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.go(Routes.aiAnalysis),
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text('View Full Screen Analysis Report →'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
}
