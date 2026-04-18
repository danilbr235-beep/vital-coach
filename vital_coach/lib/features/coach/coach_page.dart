import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'coach_models.dart';
import 'coach_providers.dart';

class CoachPage extends ConsumerStatefulWidget {
  const CoachPage({super.key});

  @override
  ConsumerState<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends ConsumerState<CoachPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final coach = ref.watch(coachControllerProvider);
    return SafeArea(
      key: const ValueKey('coach'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'Coach',
              style: t.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              coach.isSending
                  ? 'Thinking…'
                  : 'Private, evidence-aware guidance (local stub for now).',
              style: t.textTheme.bodyMedium?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount:
                  coach.thread.messages.length + (coach.error != null ? 1 : 0),
              itemBuilder: (context, i) {
                if (coach.error != null && i == coach.thread.messages.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      coach.error!,
                      style: t.textTheme.bodySmall?.copyWith(
                        color: t.colorScheme.error,
                      ),
                    ),
                  );
                }

                final m = coach.thread.messages[i];
                final isUser = m.role == CoachRole.user;
                final bg = isUser
                    ? t.colorScheme.primaryContainer.withOpacity(0.45)
                    : t.colorScheme.surfaceContainerHighest;
                final align =
                    isUser ? Alignment.centerRight : Alignment.centerLeft;

                return Align(
                  alignment: align,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Text(m.text, style: t.textTheme.bodyLarge),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Ask about your data…',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: coach.isSending
                      ? null
                      : () async {
                          final text = _controller.text;
                          _controller.clear();
                          await ref
                              .read(coachControllerProvider.notifier)
                              .send(text);
                        },
                  child: const Icon(Icons.send, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
