import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class JsonStore {
  JsonStore._(this._baseDir, this._encryptor);

  // ignore: avoid_web_libraries_in_flutter
  factory JsonStore.forDirectory(Directory baseDir, {enc.Encrypter? encryptor}) =>
      JsonStore._(baseDir, encryptor);

  final Directory _baseDir;
  final enc.Encrypter? _encryptor;

  static enc.Encrypter? _createEncryptor() {
    const keyStr = 'DiabeticCompanionKey2026Secure!';
    final key = enc.Key.fromUtf8(keyStr);
    return enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
  }

  static Future<JsonStore> create({bool encrypted = false}) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'data'));
    await dir.create(recursive: true);
    final encryptor = encrypted ? _createEncryptor() : null;
    return JsonStore._(dir, encryptor);
  }

  File _file(String name) => File(p.join(_baseDir.path, '$name.json'));

  Future<Object?> _read(String name) async {
    try {
      final f = _file(name);
      if (!await f.exists()) return null;
      var content = await f.readAsString();
      if (_encryptor != null && content.isNotEmpty) {
        try {
          final iv = enc.IV.fromUtf8(content.substring(0, 32));
          content = _encryptor.decrypt64(content.substring(32), iv: iv);
        } catch (_) {}
      }
      return jsonDecode(content);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String name, Object? data) async {
    final f = _file(name);
    var content = jsonEncode(data);
    if (_encryptor != null) {
      final iv = enc.IV.fromUtf8(
          DateTime.now().microsecondsSinceEpoch.toString().padRight(32, '0').substring(0, 32));
      content = iv.base64 + _encryptor.encrypt(content, iv: iv).base64;
    }
    final tmp = File('${f.path}.tmp');
    await tmp.writeAsString(content, flush: true);
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
