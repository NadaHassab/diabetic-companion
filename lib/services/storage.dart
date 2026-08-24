import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class JsonStore {
  JsonStore._(this._baseDir);

  factory JsonStore.forDirectory(Directory baseDir) => JsonStore._(baseDir);

  final Directory _baseDir;

  static Future<JsonStore> create() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'data'));
    await dir.create(recursive: true);
    return JsonStore._(dir);
  }

  File _file(String name) => File(p.join(_baseDir.path, '$name.json'));

  Future<Object?> _read(String name) async {
    try {
      final f = _file(name);
      if (!await f.exists()) return null;
      return jsonDecode(await f.readAsString());
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String name, Object? data) async {
    final f = _file(name);
    final tmp = File('${f.path}.tmp');
    await tmp.writeAsString(jsonEncode(data), flush: true);
    await tmp.rename(f.path);
  }

  Future<List<Map<String, dynamic>>> readList(String name) async {
    final raw = await _read(name);
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> writeList(String name, List<Map<String, dynamic>> items) =>
      write(name, items);

  Future<Map<String, dynamic>?> readMap(String name) async {
    final raw = await _read(name);
    return raw is Map<String, dynamic> ? raw : null;
  }

  Future<void> remove(String name) async {
    final f = _file(name);
    if (await f.exists()) await f.delete();
  }

  Future<String> exportToFile(Map<String, Object?> payload) async {
    final docs = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final name =
        'diabetic-companion-export-${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}.json';
    final f = File(p.join(docs.path, name));
    await f.writeAsString(const JsonEncoder.withIndent('  ').convert(payload),
        flush: true);
    return f.path;
  }
}
