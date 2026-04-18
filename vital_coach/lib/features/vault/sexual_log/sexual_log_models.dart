enum SexualLogContext { partnered, solo, other }

class SexualLogEntry {
  SexualLogEntry({
    required this.id,
    required this.when,
    required this.context,
    required this.satisfaction,
    required this.energy,
    this.notes,
  });

  final String id;
  final DateTime when;
  final SexualLogContext context;
  final int satisfaction; // 1..10
  final int energy; // 1..10
  final String? notes;

  Map<String, Object?> toJson() => {
        'id': id,
        'when': when.toIso8601String(),
        'context': context.name,
        'satisfaction': satisfaction,
        'energy': energy,
        'notes': notes,
      };

  factory SexualLogEntry.fromJson(Map<String, Object?> json) {
    final contextStr = (json['context'] ?? 'other').toString();
    final context = SexualLogContext.values.firstWhere(
      (e) => e.name == contextStr,
      orElse: () => SexualLogContext.other,
    );
    return SexualLogEntry(
      id: (json['id'] ?? '').toString(),
      when: DateTime.parse((json['when'] ?? '').toString()),
      context: context,
      satisfaction: int.tryParse((json['satisfaction'] ?? 5).toString()) ?? 5,
      energy: int.tryParse((json['energy'] ?? 5).toString()) ?? 5,
      notes: (json['notes'] ?? '') == '' ? null : (json['notes'] ?? '').toString(),
    );
  }
}

