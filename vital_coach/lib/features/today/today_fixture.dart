import 'today_models.dart';

const _fixture = <String, dynamic>{
  'mainPriorityTitle': 'Main priority',
  'mainPriorityBody':
      'Connect data sources and finish onboarding — your personal plan will appear here.',
  'nextSteps': <String>[
    'Log sleep & recovery',
    'Kegel micro-session',
    'Review learning snippet',
  ],
};

TodayDto loadTodayFixture() => TodayDto.fromJson(_fixture);

