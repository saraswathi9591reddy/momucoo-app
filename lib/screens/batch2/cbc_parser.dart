/// Pure Dart port of the OCR text parsing in frontend/src/pages/CBCAnalysis.jsx (lines 211-293).
library;

RegExp _r(String p) => RegExp(p, caseSensitive: false);

/// normalizeOcrText: drop CR, micro sign -> u, pipes -> I, commas -> dots, collapse whitespace.
String normalizeOcrText([String? text]) => (text ?? '')
    .replaceAll('\r', '')
    .replaceAll(RegExp('[µμ]'), 'u')
    .replaceAll('|', 'I')
    .replaceAll(',', '.')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// extractNumber: first pattern whose group 1 matches; keeps only digits and dots.
String extractNumber(String text, List<RegExp> patterns) {
  for (final p in patterns) {
    final m = p.firstMatch(text);
    final g = m?.group(1);
    if (g != null && g.isNotEmpty) {
      final cleaned = g.replaceAll(RegExp(r'[^\d.]'), '');
      return cleaned.isNotEmpty ? cleaned : g;
    }
  }
  return '';
}

const _num = r'(\d{1,3}(?:[.,]\d{1,2})?)';

final Map<String, List<RegExp>> _cbcPatterns = {
  'hb': [
    _r(r'(?:hemoglobin|haemoglobin|hgb|\bhb\b)[^\d\n]{0,25}' + _num),
    _r(r'(?:\bhb\b|hgb)[^\d\n]{0,12}' + _num),
  ],
  'rbc': [
    _r(r'(?:rbc|red\s*blood\s*cell(?:s)?|r8c)[^\d\n]{0,25}' + _num),
    _r(r'(?:\brbc\b|red\s*blood\s*cell(?:s)?)\D{0,25}' + _num),
  ],
  'mcv': [_r(r'\bmcv\b\D{0,20}' + _num)],
  'mch': [_r(r'\bmch(?!c)\b\D{0,20}' + _num)],
  'mchc': [_r(r'\bmchc\b\D{0,20}' + _num)],
  'hematocrit': [
    _r(r'(?:hematocrit|haematocrit|hct|pcv)[^\d\n]{0,25}' + _num),
    _r(r'\b(?:hct|pcv)\b\D{0,20}' + _num),
  ],
  'rdw': [_r(r'\brdw(?:[- ]?cv)?\b\D{0,20}' + _num)],
};

/// extractCbcValues: only keys that were found are returned (same as web).
Map<String, String> extractCbcValues(String text) {
  final t = normalizeOcrText(text).toLowerCase();
  final out = <String, String>{};
  _cbcPatterns.forEach((name, ps) {
    final v = extractNumber(t, ps);
    if (v.isNotEmpty) out[name] = v;
  });
  return out;
}

final Map<String, List<RegExp>> _scanPatterns = {
  'gestationalAge': [
    _r(r'(?:gestational(?:\s+age)?|ga)[^\d\n]{0,25}(\d{1,2})\s*(?:weeks?|wks?|w)\s*(?:\d{1,2}\s*(?:days?|d))?'),
    _r(r'(?:gestational(?:\s+age)?|ga)[^\d\n]{0,25}(\d{1,2})'),
  ],
  'fetalHeartRate': [
    _r(r'(?:fetal\s+heart\s+rate|\bfhr\b)[^\d\n]{0,25}(\d{2,3})\s*(?:bpm|beats?\s*\/\s*min)?'),
    _r(r'\b(?:fhr|fetal\s+heart)\b[^\d\n]{0,25}(\d{2,3})'),
  ],
  'estimatedWeight': [
    _r(r'(?:estimated\s+fetal\s+weight|\befw\b)[^\d\n]{0,25}(\d{2,5})\s*(?:g|grams?)'),
    _r(r'\b(?:efw|estimated\s+fetal\s+weight)\b[^\d\n]{0,25}(\d{2,5})'),
  ],
  'biparietalDiameter': [_r(r'\bbpd\b[^\d\n]{0,20}(\d+(?:[.,]\d+)?)\s*(?:cm|mm)?')],
  'headCircumference': [_r(r'\bhc\b[^\d\n]{0,20}(\d+(?:[.,]\d+)?)\s*(?:cm|mm)?')],
  'abdominalCircumference': [_r(r'\bac\b[^\d\n]{0,20}(\d+(?:[.,]\d+)?)\s*(?:cm|mm)?')],
  'femurLength': [_r(r'\b(?:femur\s+length|fl)\b[^\d\n]{0,20}(\d+(?:[.,]\d+)?)\s*(?:cm|mm)?')],
};

Map<String, String> extractScanValues(String text) {
  final t = normalizeOcrText(text).toLowerCase();
  final out = <String, String>{};
  _scanPatterns.forEach((name, ps) {
    final v = extractNumber(t, ps);
    if (v.isNotEmpty) out[name] = v;
  });
  return out;
}

/// getGestationalWeek: first 1-2 digit run as an int, else "" (web returns number or "").
Object getGestationalWeek(Object? value) {
  if (value == null || value == '' || value == 0 || value == false) return '';
  final m = RegExp(r'(\d{1,2})').firstMatch(value.toString());
  return m == null ? '' : int.parse(m.group(1)!);
}
