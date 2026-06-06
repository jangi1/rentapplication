import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rentapplication/main.dart';
import 'package:rentapplication/providers/user_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // This test builds the EasyRentApp widget.
    // Note: Since the app depends on Firebase, this test may require 
    // Firebase mocking to fully execute its logic.
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const EasyRentApp(),
      ),
    );

    // Verify that the EasyRentApp is built.
    expect(find.byType(EasyRentApp), findsOneWidget);
  });
}
