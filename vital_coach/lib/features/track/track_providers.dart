import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'track_log_models.dart';
import 'track_log_store.dart';

final trackLogStoreProvider = Provider<TrackLogStore>((ref) => TrackLogStore());

final trackLogProvider = FutureProvider<List<TrackEntry>>((ref) async {
  final store = ref.watch(trackLogStoreProvider);
  return store.list();
});

