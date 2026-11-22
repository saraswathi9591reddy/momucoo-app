import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../core/localization.dart';
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

/// Upgraded CBC Analysis Screen with instant inline Risk Level output and full localization.
class CBCAnalysisScreen extends StatefulWidget {
  const CBCAnalysisScreen({super.key, this.ocr = const MlKitOcrService()});
  final OcrService ocr;

  @override
  State<CBCAnalysisScreen> createState() => _CBCAnalysisScreenState();
}

const _fieldKeys = [
  ('hb', 'cbc_hb', 'g/dL'),
  ('rbc', 'cbc_rbc', 'million/µL'),
  ('mcv', 'cbc_mcv', 'fL'),
  ('mch', 'cbc_mch', 'pg'),
  ('mchc', 'cbc_mchc', 'g/dL'),
  ('hematocrit', 'cbc_hct', '%'),
  ('rdw', 'cbc_rdw', '%'),
];

class _CBCAnalysisScreenState extends State<CBCAnalysisScreen> {
  final _ctrl = {for (final f in _fieldKeys) f.$1: TextEditingController()};
  String _cbcFileName = '', _scanName = '', _reportStatus = '';
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
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(LocalizationService.tr('take_photo')),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(LocalizationService.tr('choose_gallery')),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
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
      setState(
        () => _reportStatus = LocalizationService.tr('upload_jpg_png_prompt'),
      );
      return;
    }
    setState(() {
      _reading = true;
      _reportStatus = LocalizationService.tr('reading_cbc');
    });
    try {
      final values = extractCbcValues(await widget.ocr.recognize(img.path));
      if (!mounted) return;
      setState(() {
        values.forEach((k, v) => _ctrl[k]?.text = v);
        _reportStatus = values.isNotEmpty
            ? '${LocalizationService.tr('copied_values')} ${values.length} ${LocalizationService.tr('values_tap_analyze')}'
            : LocalizationService.tr('no_cbc_found');
      });
      // Auto-analyze immediately if at least one value was detected!
      if (values.isNotEmpty) {
        await _analyze();
      }
    } catch (_) {
      if (mounted)
        setState(() => _reportStatus = LocalizationService.tr('cbc_cant_read'));
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> readScanReport() async {
    final src = await _chooseSource();
    if (src == null) return;
    final img = await widget.ocr.pick(src);
    if (!mounted) return;
    setState(() {
      _scanName = img?.name ?? '';
      _scanData = {};
      _inlineResult = null;
    });
    if (img == null) return;
    setState(() {
      _reading = true;
    });
    try {
      final values = extractScanValues(await widget.ocr.recognize(img.path));
      if (!mounted) return;
      setState(() {
        _scanData = values;
      });
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> _analyze() async {
    final cbcMap = {for (final e in _ctrl.entries) e.key: e.value.text};
    final s = AppStorage.instance;
    await s.saveCbcData(CbcData(cbcMap));
    await s.saveScanData(
      ScanData(
        name: _scanName,
        uploaded: _scanData.isNotEmpty,
        values: _scanData,
      ),
    );

    final res = RiskEngine.evaluate(
      cbc: cbcMap,
      pregnancy: s.readMap(StorageKeys.pregnancyData) ?? {},
      scan: _scanData,
      legacySymptoms: s.legacySymptoms,
    );

    await s.saveAiResult(res.toAiResult(DateTime.now()));
    setState(() => _inlineResult = res);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LocalizationService.currentLanguage,
      builder: (context, _, _) {
        final L = LocalizationService.tr;

        return PageLayout(
          title: L('cbc_analysis'),
          eyebrow: L('patient_portal'),
          activePath: Routes.cbcAnalysis,
          description: L('cbc_desc'),
          children: [
            ContentCard(
              kicker: L('automated_extraction'),
              title: L('upload_blood_report'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    L('upload_cbc_ocr_desc'),
                    style: const TextStyle(color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _reading ? null : _readCbcReport,
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: Text(
                      _reading ? L('reading') : L('upload_cbc_report'),
                    ),
                  ),
                  if (_cbcFileName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'File: $_cbcFileName',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (_reportStatus.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _reportStatus,
                      style: const TextStyle(
                        color: AppColors.inkSoft,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    LocalizationService.tr('ultrasound_scan_report'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LocalizationService.tr('scan_ocr_desc'),
                    style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _reading ? null : readScanReport,
                    icon: const Icon(Icons.scanner_outlined),
                    label: Text(
                      _scanName.isNotEmpty
                          ? '${LocalizationService.tr('scan_selected')}: $_scanName'
                          : LocalizationService.tr('upload_scan_report'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ContentCard(
              kicker: L('clinical_inputs'),
              title: L('cbc_parameters'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final f in _fieldKeys) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        controller: _ctrl[f.$1],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: L(f.$2),
                          suffixText: f.$3,
                          filled: true,
                          fillColor: const Color(0xFFFCF9F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5D4CE),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5D4CE),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: L('analyze_my_cbc'),
                    onPressed: _analyze,
                  ),
                ],
              ),
            ),

            if (_inlineResult != null) ...[
              const SizedBox(height: 16),
              ContentCard(
                kicker: L('instant_result'),
                title: L('preliminary_screening_result'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _inlineResult!.risk == 'Low'
                            ? const Color(0xFFD4EFDF)
                            : _inlineResult!.risk == 'Moderate'
                            ? const Color(0xFFFEF9E7)
                            : const Color(0xFFFDEDEC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${_inlineResult!.risk.toUpperCase()} ${L('risk')}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: _inlineResult!.risk == 'Low'
                                      ? AppColors.success
                                      : _inlineResult!.risk == 'Moderate'
                                      ? Colors.orange.shade800
                                      : AppColors.primary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${L('score')}: ${_inlineResult!.score}/100',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _inlineResult!.anemiaLikely
                                ? L('anemia_detected')
                                : L('no_anemia_detected'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => context.go(Routes.aiAnalysis),
                      icon: const Icon(Icons.analytics_outlined),
                      label: Text(L('view_full_report_btn')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
