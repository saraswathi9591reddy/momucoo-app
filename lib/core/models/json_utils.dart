/// Mirrors JS `Number(x) || 0`.
double jsNumber(dynamic v) {
  if (v == null || v is bool) return v == true ? 1 : 0;
  if (v is num) return v.isNaN ? 0 : v.toDouble();
  final s = v.toString().trim();
  if (s.isEmpty) return 0;
  return double.tryParse(s) ?? 0;
}

/// Mirrors JS truthiness for JSON values.
bool jsTruthy(dynamic v) => !(v == null || v == false || v == '' || v == 0 || (v is double && v.isNaN));
