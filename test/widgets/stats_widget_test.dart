import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dash/widgets/stats_widget.dart';

void main() {
  testWidgets('StatsWidget renders correctly with all styling and padding', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: StatsWidget()),
      ),
    ));

    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('152'), findsOneWidget);
    expect(find.textContaining('24 new', findRichText: true), findsOneWidget);

    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text('\$2,100'), findsOneWidget);

    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('28441'), findsOneWidget);

    expect(find.text('Comments'), findsOneWidget);
    expect(find.text('152 Unread'), findsOneWidget);
    
    expect(find.byType(Card), findsNWidgets(4));
    expect(find.byType(Icon), findsNWidgets(4));

    // Inspect the first card to kill _buildStatCard numeric mutations
    final card = tester.widget<Card>(find.byType(Card).first);
    expect(card.elevation, 0);
    
    final shape = card.shape as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(12));
    expect(shape.side.color.a, closeTo(0.2, 0.01)); // withValues(alpha: 0.2)

    expect(find.byWidgetPredicate((w) => w is Padding && w.padding == const EdgeInsets.all(16.0)), findsWidgets);

    // Value text styling (kills fontSize: 24)
    final valueText = tester.widget<Text>(find.text('152'));
    expect(valueText.style?.fontSize, 24);

    // Icon Container (kills width 40, height 40, borderRadius 8)
    final container = tester.widget<Container>(find.descendant(
      of: find.byType(Card).first,
      matching: find.byType(Container).first,
    ));
    expect(container.constraints?.maxWidth, 40);
    expect(container.constraints?.maxHeight, 40);
    final boxDec = container.decoration as BoxDecoration;
    expect(boxDec.borderRadius, BorderRadius.circular(8));

    // RichText styling (kills fontSize: 14)
    final richText = tester.widget<RichText>(find.descendant(
      of: find.byType(Card).first,
      matching: find.byType(RichText).first,
    ));
    expect(richText.text.style?.fontSize, 14);

    // Check all SizedBoxes (kills height 8, 16)
    expect(find.byWidgetPredicate((w) => w is SizedBox && w.height == 8), findsNWidgets(4));
    expect(find.byWidgetPredicate((w) => w is SizedBox && w.height == 16), findsNWidgets(7)); // 4 inside cards, 3 between cards

    // Assert specific %52+ mutation
    expect(find.textContaining('%52+', findRichText: true), findsOneWidget);

    // Assert specific alpha colors
    final containersWithAlpha = tester.widgetList<Container>(find.byWidgetPredicate((w) {
      if (w is Container && w.decoration is BoxDecoration) {
        final color = (w.decoration as BoxDecoration).color;
        return color != null && (color.a - 0.1).abs() < 0.01;
      }
      return false;
    })).toList();
    expect(containersWithAlpha.length, 4);
    await tester.pumpWidget(Container());
  });
}

