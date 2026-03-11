import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/core/network/health_api.dart';
import 'package:mobile/src/core/network/health_status.dart';
import 'package:mobile/src/features/home/application/health_status_provider.dart';
import 'package:mobile/src/features/home/presentation/home_page.dart';

class FakeHealthApi implements HealthApi {
  FakeHealthApi(this._result);

  final Future<HealthStatus> Function() _result;

  @override
  Future<HealthStatus> fetchHealthStatus() {
    return _result();
  }
}

void main() {
  testWidgets('shows health status when request succeeds', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthApiProvider.overrideWithValue(
            FakeHealthApi(
              () async => const HealthStatus(status: 'ok', version: '0.1.0'),
            ),
          ),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    await tester.pump();

    expect(find.text('Server OK'), findsOneWidget);
    expect(find.text('Version 0.1.0'), findsOneWidget);
  });

  testWidgets('shows error message when request fails', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthApiProvider.overrideWithValue(
            FakeHealthApi(() async => throw Exception('network down')),
          ),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    await tester.pump();

    expect(find.text('Unable to reach server'), findsOneWidget);
    expect(find.textContaining('network down'), findsOneWidget);
  });
}
