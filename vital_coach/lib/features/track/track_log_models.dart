enum TrackEntryType { kegel, pump, recovery }

class TrackEntry {
  TrackEntry({
    required this.id,
    required this.type,
    required this.startedAt,
    required this.endedAt,
    this.meta = const {},
  });

  final String id;
  final TrackEntryType type;
  final DateTime startedAt;
  final DateTime endedAt;
  final Map<String, Object?> meta;

  Map<String, Object?> toJson() => {
        'id': id,
        'type': type.name,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'meta': meta,
      };

  factory TrackEntry.fromJson(Map<String, Object?> json) {
    final typeStr = (json['type'] ?? 'recovery').toString();
    final type = TrackEntryType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => TrackEntryType.recovery,
    );
    return TrackEntry(
      id: (json['id'] ?? '').toString(),
      type: type,
      startedAt: DateTime.parse((json['startedAt'] ?? '').toString()),
      endedAt: DateTime.parse((json['endedAt'] ?? '').toString()),
      meta: (json['meta'] as Map?)?.cast<String, Object?>() ?? const {},
    );
  }
}

