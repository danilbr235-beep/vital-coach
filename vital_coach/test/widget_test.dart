import 'package:flutter_test/flutter_test.dart';
import 'package:vital_coach/main.dart';

void main() {
  testWidgets('app boots with Today label', (tester) async {
    await tester.pumpWidget(const VitalCoachApp());
    expect(find.text('Main priority'), findsOneWidget);
  });
}
