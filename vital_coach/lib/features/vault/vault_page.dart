import 'package:flutter/material.dart';

class VaultPage extends StatelessWidget {
  const VaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Vault')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Private space',
                style: t.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This section will contain sensitive logs (MVP: placeholder).',
                style: t.textTheme.bodyMedium?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Sexual wellness log'),
                  subtitle: const Text('Private entries (coming next)'),
                  onTap: () {},
                ),
              ),
              Card(
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Partner notes'),
                  subtitle: const Text('Private notes (coming next)'),
                  onTap: () {},
                ),
              ),
              Card(
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.photo_outlined),
                  title: const Text('Appearance photos'),
                  subtitle: const Text('Local-only by default (coming next)'),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

