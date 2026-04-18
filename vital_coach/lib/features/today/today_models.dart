class TodayDto {
  TodayDto({
    required this.mainPriorityTitle,
    required this.mainPriorityBody,
    required this.nextSteps,
  });

  final String mainPriorityTitle;
  final String mainPriorityBody;
  final List<String> nextSteps;

  factory TodayDto.fromJson(Map<String, dynamic> json) {
    final steps = (json['nextSteps'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(growable: false);
    return TodayDto(
      mainPriorityTitle: (json['mainPriorityTitle'] ?? '').toString(),
      mainPriorityBody: (json['mainPriorityBody'] ?? '').toString(),
      nextSteps: steps,
    );
  }
}

