import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brainvita/main.dart';

void main() {
  testWidgets('Brainvita renders board with stats', (tester) async {
    await tester.pumpWidget(const BrainvitaApp());
    await tester.pump();

    expect(find.text('Brainvita'), findsOneWidget);
    expect(find.text('PEGS'), findsOneWidget);
    expect(find.text('MOVES'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('32'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
  });

  testWidgets('Brainvita renders without overflow on narrow phone',
      (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BrainvitaApp());
    await tester.pump();

    expect(find.text('PEGS'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
