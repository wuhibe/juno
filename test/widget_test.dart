// Smoke test for the Juno app shell: verifies the themed connections list
// renders its empty state.
//
// connectionsListProvider is overridden with a direct empty stream so the test
// neither touches the on-device database (covered by the data-layer tests) nor
// stalls on the loading spinner.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juno/data/data_providers.dart';
import 'package:juno/data/models/saved_connection.dart';
import 'package:juno/main.dart';

void main() {
  setUpAll(() {
    // Keep tests offline & deterministic: never fetch Google Fonts over the
    // network during a test run (fall back to the default font).
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('home screen shows the empty-connections state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectionsListProvider.overrideWith(
            (ref) =>
                Stream<List<SavedConnection>>.value(const <SavedConnection>[]),
          ),
        ],
        child: const JunoApp(),
      ),
    );
    // Let the stream deliver its value and rebuild past the loading spinner.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Juno'), findsOneWidget);
    expect(find.text('No connections yet'), findsOneWidget);
  });
}
