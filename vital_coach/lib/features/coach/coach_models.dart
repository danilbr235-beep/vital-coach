enum CoachRole { user, assistant, system }

class CoachMessage {
  CoachMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final CoachRole role;
  final String text;
  final DateTime createdAt;
}

class CoachThread {
  CoachThread({required this.id, required this.messages});

  final String id;
  final List<CoachMessage> messages;

  CoachThread copyWith({List<CoachMessage>? messages}) {
    return CoachThread(id: id, messages: messages ?? this.messages);
  }
}

