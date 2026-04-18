import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'today_providers.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final today = ref.watch(todayProvider);
    return SafeArea(
      key: const ValueKey('today'),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Today',
                style: t.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 0,
                color: t.colorScheme.primaryContainer.withOpacity(0.35),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        today.mainPriorityTitle,
                        style: t.textTheme.labelLarge?.copyWith(
                          color: t.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        today.mainPriorityBody,
                        style: t.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Continue setup'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Next steps',
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: today.nextSteps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                return ListTile(
                  tileColor: t.colorScheme.surfaceContainerHighest
                      .withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(today.nextSteps[i]),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
