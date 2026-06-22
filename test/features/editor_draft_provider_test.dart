import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juno/features/editor/application/editor_draft_provider.dart';

void main() {
  test('load sets a draft and clear resets it', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(editorDraftRequestProvider), isNull);

    container.read(editorDraftRequestProvider.notifier).load('SELECT 1');
    final draft = container.read(editorDraftRequestProvider);
    expect(draft?.sql, 'SELECT 1');
    expect(draft?.run, isFalse);

    container.read(editorDraftRequestProvider.notifier).clear();
    expect(container.read(editorDraftRequestProvider), isNull);
  });

  test('load with run flags an auto-run draft', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(editorDraftRequestProvider.notifier)
        .load('SELECT 2', run: true);
    expect(container.read(editorDraftRequestProvider)?.run, isTrue);
  });
}
