import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app.dart';
import 'package:flutter_app/state/app_state.dart';

void main() {
  testWidgets('App renders title, disclaimer banner, and navigation tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final state = AppState(enablePolling: false);
    addTearDown(state.dispose);

    await tester.pumpWidget(HealthMonitoringApp(state: state));
    await tester.pump();

    // Check title
    expect(find.text('IoT Health Monitor'), findsOneWidget);

    // Check disclaimer presence (FR-16)
    expect(find.textContaining('NON-DIAGNOSTIC PROTOTYPE'), findsOneWidget);

    // Check navigation labels
    expect(find.text('Overview'), findsWidgets);
    expect(find.text('History'), findsWidgets);
    expect(find.text('Alerts'), findsWidgets);
    expect(find.text('Devices'), findsWidgets);
    expect(find.text('Tests'), findsWidgets);
  });
}
