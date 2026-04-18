import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kegel/kegel_session_page.dart';
import 'pump/pump_session_page.dart';
import 'recovery/recovery_reset_page.dart';
import 'track_log_models.dart';
import 'track_log_store.dart';
import 'track_providers.dart';

class TrackPage extends ConsumerWidget {
  const TrackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final log = ref.watch(trackLogProvider);
    final logStore = ref.watch(trackLogStoreProvider);
    return SafeArea(
      key: const ValueKey('track'),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Track',
            style: t.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wearables, labs, habits, programs — grouped here as modules are '
            'implemented.',
            style: t.textTheme.bodyMedium?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: const Text('Kegel session'),
              subtitle: const Text('Technique + timer (MVP)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => KegelSessionPage(logStore: logStore),
                ),
              ),
            ),
          ),
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: const Text('Pump session'),
              subtitle: const Text('Safety-first timer (MVP)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PumpSessionPage(logStore: logStore),
                ),
              ),
            ),
          ),
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: const Text('Recovery reset'),
              subtitle: const Text('5-minute downshift (MVP)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecoveryResetPage(logStore: logStore),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Recent',
            style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          log.when(
            data: (items) {
              if (items.isEmpty) {
                return Text(
                  'No entries yet.',
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                );
              }
              return Column(
                children: items.take(8).map((e) {
                  final label = _labelForType(e.type);
                  final mins = e.endedAt.difference(e.startedAt).inMinutes;
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(label),
                      subtitle: Text(_formatWhen(e.startedAt)),
                      trailing: Text('${mins}m'),
                    ),
                  );
                }).toList(growable: false),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (err, _) => Text(
              err.toString(),
              style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.error),
            ),
          ),
          for (final label in [
            'Devices & sync',
            'Body metrics',
            'Sexual wellness logs (private vault)',
          ])
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(label),
                trailing: const Icon(Icons.lock_outline, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}

String _labelForType(TrackEntryType t) {
  switch (t) {
    case TrackEntryType.kegel:
      return 'Kegel';
    case TrackEntryType.pump:
      return 'Pump';
    case TrackEntryType.recovery:
      return 'Recovery reset';
  }
}

String _formatWhen(DateTime dt) {
  final d = dt.toLocal();
  final yyyy = d.year.toString().padLeft(4, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  return '$yyyy-$mm-$dd $hh:$min';
}
