/// localStorage key `scanData`: {name, uploaded, values: {gestationalAge, ...}, uploadedAt}.
class ScanData {
  String name;
  bool uploaded;
  Map<String, dynamic> values;
  String? uploadedAt;

  ScanData({this.name = '', this.uploaded = false, Map<String, dynamic>? values, this.uploadedAt})
      : values = values ?? {};

  factory ScanData.fromJson(Map<String, dynamic> j) => ScanData(
        name: (j['name'] ?? '').toString(),
        uploaded: j['uploaded'] == true,
        values: j['values'] is Map ? Map<String, dynamic>.from(j['values'] as Map) : {},
        uploadedAt: j['uploadedAt'] as String?,
      );

  Map<String, dynamic> toJson() => {'name': name, 'uploaded': uploaded, 'values': values, 'uploadedAt': uploadedAt};
}
