import 'package:flutter/material.dart';

import '../track_log_models.dart';
import '../track_log_store.dart';

class KegelSessionPage extends StatefulWidget {
  const KegelSessionPage({super.key, required this.logStore});

  final TrackLogStore logStore;

  @override
  State<KegelSessionPage> createState() => _KegelSessionPageState();
}

class _KegelSessionPageState extends State<KegelSessionPage> {
  static const _holdSeconds = 3;
  static const _restSeconds = 6;
  static const _reps = 10;

  int _rep = 0;
  bool _isHolding = true;
  bool _running = false;
  int _secondsLeft = _holdSeconds;
  DateTime? _startedAt;
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _rep = 1;
      _isHolding = true;
      _running = true;
      _secondsLeft = _holdSeconds;
      _startedAt = DateTime.now();
    });

    // Simple async loop timer (MVP). Replace with better ticker later.
    while (mounted && _running) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted || !_running) break;

      setState(() => _secondsLeft -= 1);

      if (_secondsLeft > 0) continue;

      if (_isHolding) {
        setState(() {
          _isHolding = false;
          _secondsLeft = _restSeconds;
        });
        continue;
      }

      if (_rep >= _reps) {
        setState(() => _running = false);
        if (!mounted) return;
        await _saveLog(completed: true);
        await _showDone();
        return;
      }

      setState(() {
        _rep += 1;
        _isHolding = true;
        _secondsLeft = _holdSeconds;
      });
    }
  }

  void _stop() {
    setState(() => _running = false);
  }

  Future<void> _saveLog({required bool completed}) async {
    final startedAt = _startedAt ?? DateTime.now();
    final endedAt = DateTime.now();
    await widget.logStore.add(
      TrackEntry(
        id: 'k_${endedAt.microsecondsSinceEpoch}',
        type: TrackEntryType.kegel,
        startedAt: startedAt,
        endedAt: endedAt,
        meta: <String, Object?>{
          'completed': completed,
          'repsTarget': _reps,
          'repsDone': _rep,
          'holdSeconds': _holdSeconds,
          'restSeconds': _restSeconds,
        },
      ),
    );
  }

  Future<void> _showDone() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Done'),
        content: const Text('Nice work. Log saved (stub).'),
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
    final phase = _isHolding ? 'Hold' : 'Rest';

    return Scaffold(
      appBar: AppBar(title: const Text('Kegel session')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Technique first',
                style: t.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stop if you feel pain. Keep breath relaxed. Avoid using abs/glutes.',
                style: t.textTheme.bodyMedium?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Text(
                        _running ? phase : 'Ready',
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _running ? '$_secondsLeft s' : '$_reps reps',
                        style: t.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _rep == 0 ? '' : 'Rep $_rep / $_reps',
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: t.colorScheme.onSurfaceVariant,
                        ),
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

