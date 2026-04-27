import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pesotrack/app/app.dart';

void main() {
  testWidgets('renders home structure', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PesoTrackApp()));

    expect(find.text('Seu peso, com calma.'), findsOneWidget);
  });
}
