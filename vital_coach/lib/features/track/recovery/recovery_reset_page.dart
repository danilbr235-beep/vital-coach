import 'package:flutter/material.dart';

import '../track_log_models.dart';
import '../track_log_store.dart';

class RecoveryResetPage extends StatefulWidget {
  const RecoveryResetPage({super.key, required this.logStore});

  final TrackLogStore logStore;

  @override
  State<RecoveryResetPage> createState() => _RecoveryResetPageState();
}

class _RecoveryResetPageState extends State<RecoveryResetPage> {
  static const _minutes = 5;
  bool _running = false;
  int _secondsLeft = _minutes * 60;
  DateTime? _startedAt;

  Future<void> _start() async {
    setState(() {
      _running = true;
      _secondsLeft = _minutes * 60;
      _startedAt = DateTime.now();
    });

    while (mounted && _running) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted || !_running) break;
      setState(() => _secondsLeft -= 1);
      if (_secondsLeft <= 0) {
        setState(() => _running = false);
        if (!mounted) return;
        await _saveLog(completed: true);
        await _showDone();
        return;
      }
    }
  }

  void _stop() => setState(() => _running = false);

  Future<void> _saveLog({required bool completed}) async {
    final startedAt = _startedAt ?? DateTime.now();
    final endedAt = DateTime.now();
    final durationSeconds = (_minutes * 60 - _secondsLeft).clamp(0, _minutes * 60);
    await widget.logStore.add(
      TrackEntry(
        id: 'r_${endedAt.microsecondsSinceEpoch}',
        type: TrackEntryType.recovery,
        startedAt: startedAt,
        endedAt: endedAt,
        meta: <String, Object?>{
          'completed': completed,
          'targetMinutes': _minutes,
          'durationSeconds': durationSeconds,
        },
      ),
    );
  }

  Future<void> _showDone() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recovery reset complete'),
        content: const Text('Nice. Small consistency beats intensity.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final mm = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final ss = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: const Text('Recovery reset')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '5-minute downshift',
                style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Breathe slowly, relax jaw/shoulders, drink water. This is a simple reset, not therapy.',
                style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Text(
                        _running ? 'Running' : 'Ready',
                        style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$mm:$ss',
                        style: t.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _running
                    ? () async {
                        _stop();
                        await _saveLog(completed: false);
                      }
                    : _start,
                child: Text(_running ? 'Stop' : 'Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

