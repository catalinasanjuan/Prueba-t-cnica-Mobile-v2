import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/widgets/network_error_widget.dart';
import 'package:notes_app/widgets/loading_overlay.dart';

void main() {
  group('NetworkErrorWidget', () {
    testWidgets('shows error message and retry button', (tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NetworkErrorWidget(
              message: 'Test error message',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      expect(retryPressed, true);
    });
  });

  group('LoadingOverlay', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: true,
              message: 'Loading...',
              child: SizedBox(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('hides loading indicator when not loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingOverlay(
              isLoading: false,
              message: 'Loading...',
              child: SizedBox(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Loading...'), findsNothing);
    });
  });
}