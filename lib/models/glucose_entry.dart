import 'context_tag.dart';

class GlucoseEntry {
  GlucoseEntry({
    required this.id,
    required this.recordedAt,
    required this.mgdl,
    Set<ContextTag>? tags,
    this.note = '',
    this.confirmedUnusual = false,
  }) : tags = Set<ContextTag>.unmodifiable(tags ?? const <ContextTag>{});

  final String id;
  final DateTime recordedAt;
  final double mgdl;
  final Set<ContextTag> tags;
  final String note;
  final bool confirmedUnusual;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'recordedAt': recordedAt.toIso8601String(),
        'mgdl': mgdl,
        'tags': tags.map((t) => t.name).toList(),
        'note': note,
        'confirmedUnusual': confirmedUnusual,
      };

  factory GlucoseEntry.fromJson(Map<String, dynamic> json) => GlucoseEntry(
        id: json['id'] as String,
        recordedAt: DateTime.parse(json['recordedAt'] as String),
        mgdl: (json['mgdl'] as num).toDouble(),
        tags: ((json['tags'] as List?) ?? const [])
            .map((e) => ContextTag.values.byName(e as String))
            .toSet(),
        note: (json['note'] as String?) ?? '',
        confirmedUnusual: (json['confirmedUnusual'] as bool?) ?? false,
      );

  bool inRange(double low, double high) => mgdl >= low && mgdl <= high;
}
