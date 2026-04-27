import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pesotrack/app/app.dart';

void main() {
  testWidgets('renders onboarding on first access', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: PesoTrackApp()));
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo ao PesoTrack'), findsOneWidget);
  });
}
