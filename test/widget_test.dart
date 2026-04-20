import 'package:flutter_test/flutter_test.dart';
import 'package:naru_client/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NaruApp());
    expect(find.byType(NaruApp), findsOneWidget);
  });
}
