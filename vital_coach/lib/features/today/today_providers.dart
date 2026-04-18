import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'today_fixture.dart';
import 'today_models.dart';

final todayProvider = Provider<TodayDto>((ref) {
  // Stub: later becomes rule-engine output + sync data snapshot.
  return loadTodayFixture();
});

