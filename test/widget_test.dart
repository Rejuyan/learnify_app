import 'package:flutter_test/flutter_test.dart';

import 'package:learnify_app/main.dart';

void main() {
  testWidgets('Learnify app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LearnifyApp());
    expect(find.text('Learnify'), findsAny);
  });
}
