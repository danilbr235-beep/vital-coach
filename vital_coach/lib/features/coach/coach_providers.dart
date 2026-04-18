import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'coach_models.dart';
import 'coach_service.dart';

final coachServiceProvider = Provider<CoachService>((ref) {
  return LocalCoachStubService();
});

class CoachState {
  CoachState({
    required this.thread,
    required this.isSending,
    this.error,
  });

  final CoachThread thread;
  final bool isSending;
  final String? error;

  CoachState copyWith({
    CoachThread? thread,
    bool? isSending,
    String? error,
  }) {
    return CoachState(
      thread: thread ?? this.thread,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

class CoachController extends Notifier<CoachState> {
  @override
  CoachState build() {
    final thread = CoachThread(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      messages: [
        CoachMessage(
          id: 'sys_0',
          role: CoachRole.assistant,
          text:
              'Tell me what you want to improve. I’ll keep it private and actionable.',
          createdAt: DateTime.now(),
        ),
      ],
    );
    return CoachState(thread: thread, isSending: false);
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (state.isSending) return;

    final userMsg = CoachMessage(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      role: CoachRole.user,
      text: trimmed,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      isSending: true,
      error: null,
      thread: state.thread.copyWith(
        messages: [...state.thread.messages, userMsg],
      ),
    );

    try {
      final svc = ref.read(coachServiceProvider);
      final reply = await svc.respond(thread: state.thread, userText: trimmed);
      state = state.copyWith(
        isSending: false,
        thread: state.thread.copyWith(
          messages: [...state.thread.messages, reply],
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }
}

final coachControllerProvider =
    NotifierProvider<CoachController, CoachState>(CoachController.new);

