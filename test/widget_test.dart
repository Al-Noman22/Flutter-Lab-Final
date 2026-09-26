import 'package:flutter_test/flutter_test.dart';
import 'package:quizzical/main.dart';

void main() {
  testWidgets('App starts and shows Quizzical title', (WidgetTester tester) async {
    await tester.pumpWidget(const QuizzicalApp());

    // Verify that Quizzical title and GET STARTED button are present
    expect(find.text('Quizzical'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
  });
}
