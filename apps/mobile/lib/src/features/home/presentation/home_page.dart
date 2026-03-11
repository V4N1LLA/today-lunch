import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/health_status_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiConfig = ref.watch(appApiConfigProvider);
    final healthStatus = ref.watch(healthStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('today-lunch')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Server status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              apiConfig.baseUrl,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            healthStatus.when(
              data: (value) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Server ${value.status.toUpperCase()}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Version ${value.version}'),
                  ],
                );
              },
              loading: () {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Checking server...'),
                  ],
                );
              },
              error: (error, stackTrace) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unable to reach server',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(error.toString()),
                  ],
                );
              },
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => ref.invalidate(healthStatusProvider),
              child: const Text('Refresh health'),
            ),
          ],
        ),
      ),
    );
  }
}
