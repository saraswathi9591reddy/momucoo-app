/// localStorage key `cbcData`. Values are strings (form inputs / OCR output), as on web.
class CbcData {
  static const fields = ['hb', 'rbc', 'mcv', 'mch', 'mchc', 'hematocrit', 'rdw'];
  final Map<String, String> values;

  CbcData([Map<String, String>? v]) : values = {for (final f in fields) f: v?[f] ?? ''};

  factory CbcData.fromJson(Map<String, dynamic> j) =>
      CbcData({for (final e in j.entries) e.key: e.value?.toString() ?? ''});

  String operator [](String k) => values[k] ?? '';
  void operator []=(String k, String v) => values[k] = v;

  Map<String, dynamic> toJson() => Map<String, dynamic>.of(values);
}
