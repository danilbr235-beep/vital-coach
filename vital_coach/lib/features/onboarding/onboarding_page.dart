import 'package:flutter/material.dart';

import '../../app/storage/app_prefs.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _step = 0;
  String? _goal;
  String? _language;

  bool get _canContinue {
    if (_step == 0) return _goal != null;
    if (_step == 1) return _language != null;
    return true;
  }

  Future<void> _finish() async {
    await AppPrefs.setOnboardingDone(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/app');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Private coach, built for you.',
                style: t.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We start with two quick questions. You can change everything later.',
                style: t.textTheme.bodyMedium?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(child: _StepBody(step: _step, onSelect: _onSelect)),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: () => setState(() => _step -= 1),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _canContinue
                        ? () async {
                            if (_step < 1) {
                              setState(() => _step += 1);
                              return;
                            }
                            await _finish();
                          }
                        : null,
                    child: Text(_step < 1 ? 'Continue' : 'Finish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSelect(String key, String value) {
    setState(() {
      if (key == 'goal') _goal = value;
      if (key == 'language') _language = value;
    });
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.step, required this.onSelect});

  final int step;
  final void Function(String key, String value) onSelect;

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return _ChoiceList(
          title: 'What is your main focus?',
          choices: const [
            ('erection', 'Erection & sexual wellbeing'),
            ('recovery', 'Recovery, sleep & energy'),
            ('confidence', 'Confidence & routines'),
          ],
          onTap: (v) => onSelect('goal', v),
        );
      case 1:
        return _ChoiceList(
          title: 'Preferred language',
          choices: const [
            ('en', 'English'),
            ('ru', 'Русский'),
          ],
          onTap: (v) => onSelect('language', v),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ChoiceList extends StatelessWidget {
  const _ChoiceList({
    required this.title,
    required this.choices,
    required this.onTap,
  });

  final String title;
  final List<(String, String)> choices;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        for (final c in choices)
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(c.$2),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onTap(c.$1),
            ),
          ),
      ],
    );
  }
}

