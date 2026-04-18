import 'dart:math';

import 'coach_models.dart';

abstract class CoachService {
  Future<CoachMessage> respond({
    required CoachThread thread,
    required String userText,
  });
}

/// Local placeholder to unblock UI/dev. Replace with an Edge Function client.
class LocalCoachStubService implements CoachService {
  final _rng = Random();

  @override
  Future<CoachMessage> respond({
    required CoachThread thread,
    required String userText,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final normalized = userText.trim().toLowerCase();
    final hint = _hint(normalized);

    return CoachMessage(
      id: 'a_${DateTime.now().microsecondsSinceEpoch}_${_rng.nextInt(9999)}',
      role: CoachRole.assistant,
      text: [
        'Got it.',
        if (hint != null) hint,
        '',
        'Next: connect devices / labs and I’ll start summarizing trends safely.',
      ].where((s) => s.isNotEmpty).join('\n'),
      createdAt: DateTime.now(),
    );
  }

  String? _hint(String t) {
    if (t.contains('sleep') || t.contains('сон')) {
      return 'If you share sleep duration + wake time, I can propose a tiny recovery step for Today.';
    }
    if (t.contains('kegel') || t.contains('кег')) {
      return 'For Kegels: we’ll start with technique + low volume, then progress weekly.';
    }
    if (t.contains('pump') || t.contains('помп')) {
      return 'Pump training needs conservative protocols and stop-rules; we’ll implement those in Track.';
    }
    if (t.contains('lab') || t.contains('анализ')) {
      return 'You can upload PDFs/photos later; I’ll extract markers and draft “doctor brief” summaries.';
    }
    return null;
  }
}

