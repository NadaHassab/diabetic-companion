import 'dart:convert';
import 'package:web/web.dart' as web;

class JsonStore {
  JsonStore._();

  static Future<JsonStore> create({bool encrypted = false}) async {
    return JsonStore._();
  }

  Object? _read(String name) {
    try {
      final raw = web.window.localStorage.getItem('dc_$name');
      if (raw == null) return null;
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String name, Object? data) async {
    web.window.localStorage.setItem('dc_$name', jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>> readList(String name) async {
    final raw = _read(name);
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> writeList(String name, List<Map<String, dynamic>> items) =>
      write(name, items);

  Future<Map<String, dynamic>?> readMap(String name) async {
    final raw = _read(name);
    return raw is Map<String, dynamic> ? raw : null;
  }

  Future<void> remove(String name) async {
    web.window.localStorage.removeItem('dc_$name');
  }

  Future<String> exportToFile(Map<String, Object?> payload) async {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final name =
        'diabetic-companion-export-${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}.json';
    final jsonStr = const JsonEncoder.withIndent('  ').convert(payload);
    final dataUri = 'data:application/json;charset=utf-8,${Uri.encodeComponent(jsonStr)}';
    web.HTMLAnchorElement()
      ..href = dataUri
      ..download = name
      ..click();
    return name;
  }
}
