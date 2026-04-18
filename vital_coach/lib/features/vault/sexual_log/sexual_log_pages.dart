import 'package:flutter/material.dart';

import 'sexual_log_models.dart';
import 'sexual_log_store.dart';

class SexualLogListPage extends StatefulWidget {
  const SexualLogListPage({super.key, required this.store});

  final SexualLogStore store;

  @override
  State<SexualLogListPage> createState() => _SexualLogListPageState();
}

class _SexualLogListPageState extends State<SexualLogListPage> {
  late Future<List<SexualLogEntry>> _future = widget.store.list();

  Future<void> _reload() async {
    setState(() => _future = widget.store.list());
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sexual wellness log'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => SexualLogAddPage(store: widget.store),
            ),
          );
          if (added == true) await _reload();
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: FutureBuilder<List<SexualLogEntry>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data ?? const [];
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No entries yet.\nTap + to add a private entry.',
                    textAlign: TextAlign.center,
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: t.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final e = items[i];
                return Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.favorite_border),
                    title: Text(_formatWhen(e.when)),
                    subtitle: Text(
                      '${_labelContext(e.context)} · satisfaction ${e.satisfaction}/10 · energy ${e.energy}/10',
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SexualLogAddPage extends StatefulWidget {
  const SexualLogAddPage({super.key, required this.store});

  final SexualLogStore store;

  @override
  State<SexualLogAddPage> createState() => _SexualLogAddPageState();
}

class _SexualLogAddPageState extends State<SexualLogAddPage> {
  SexualLogContext _context = SexualLogContext.partnered;
  double _satisfaction = 7;
  double _energy = 7;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final entry = SexualLogEntry(
      id: 'sx_${now.microsecondsSinceEpoch}',
      when: now,
      context: _context,
      satisfaction: _satisfaction.round().clamp(1, 10),
      energy: _energy.round().clamp(1, 10),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    await widget.store.add(entry);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('New entry'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Context',
              style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<SexualLogContext>(
              segments: const [
                ButtonSegment(value: SexualLogContext.partnered, label: Text('Partnered')),
                ButtonSegment(value: SexualLogContext.solo, label: Text('Solo')),
                ButtonSegment(value: SexualLogContext.other, label: Text('Other')),
              ],
              selected: {_context},
              onSelectionChanged: (s) => setState(() => _context = s.first),
            ),
            const SizedBox(height: 24),
            Text(
              'Satisfaction: ${_satisfaction.round()}/10',
              style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _satisfaction,
              min: 1,
              max: 10,
              divisions: 9,
              label: _satisfaction.round().toString(),
              onChanged: (v) => setState(() => _satisfaction = v),
            ),
            const SizedBox(height: 8),
            Text(
              'Energy: ${_energy.round()}/10',
              style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _energy,
              min: 1,
              max: 10,
              divisions: 9,
              label: _energy.round().toString(),
              onChanged: (v) => setState(() => _energy = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notes,
              minLines: 3,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Privacy note: this is stored locally (MVP). We’ll add encryption + export later.',
              style: t.textTheme.bodySmall?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _labelContext(SexualLogContext c) {
  switch (c) {
    case SexualLogContext.partnered:
      return 'Partnered';
    case SexualLogContext.solo:
      return 'Solo';
    case SexualLogContext.other:
      return 'Other';
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

