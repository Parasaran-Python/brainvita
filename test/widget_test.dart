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
}
