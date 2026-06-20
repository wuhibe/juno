// Smoke test for the Juno app shell: verifies the themed home screen renders.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:juno/main.dart';

void main() {
  setUpAll(() {
    // Keep tests offline & deterministic: never fetch Google Fonts over the
    // network during a test run (fall back to the default font).
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('home screen shows the empty-connections state', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: JunoApp()));
    await tester.pumpAndSettle();

    expect(find.text('Juno'), findsOneWidget);
    expect(find.text('No connections yet'), findsOneWidget);
  });
}
