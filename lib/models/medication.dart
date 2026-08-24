class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.times,
  });

  final String id;
  final String name;
  final List<String> times;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'times': times,
      };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] as String,
        name: (json['name'] as String?) ?? '',
        times: ((json['times'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );

  Medication copyWith({String? name, List<String>? times}) => Medication(
        id: id,
        name: name ?? this.name,
        times: times ?? this.times,
      );
}

class MedIntake {
  const MedIntake({
    required this.id,
    required this.medicationId,
    required this.takenAt,
  });

  final String id;
  final String medicationId;
  final DateTime takenAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'medicationId': medicationId,
        'takenAt': takenAt.toIso8601String(),
      };

  factory MedIntake.fromJson(Map<String, dynamic> json) => MedIntake(
        id: json['id'] as String,
        medicationId: json['medicationId'] as String,
        takenAt: DateTime.parse(json['takenAt'] as String),
      );
}
