/// Helpers de parsing JSON API (nombres parfois renvoyés en chaîne).
int parseInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? fallback;
}

double parseDouble(dynamic v, [double fallback = 0]) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? fallback;
}
