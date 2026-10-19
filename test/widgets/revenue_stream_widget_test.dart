import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dash/widgets/revenue_stream_widget.dart';

void main() {
  testWidgets('RevenueStreamWidget renders correctly with styling', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: RevenueStreamWidget()),
      ),
    ));

    expect(find.text('Revenue Stream'), findsOneWidget);
    final titleText = tester.widget<Text>(find.text('Revenue Stream'));
    expect(titleText.style?.fontSize, 20);

    // Assert Card styling (kills elevation: 0, borderRadius: 12, alpha: 0.2)
    final card = tester.widget<Card>(find.byType(Card).first);
    expect(card.elevation, 0);
    final shape = card.shape as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(12));
    expect(shape.side.color.a, closeTo(0.2, 0.01));

    // Assert padding (kills 16.0)
    expect(find.byWidgetPredicate((w) => w is Padding && w.padding == const EdgeInsets.all(16.0)), findsWidgets);

    // Assert SizedBox height (kills 16, 8)
    final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    expect(sizedBoxes.any((box) => box.height == 16), true);
    expect(sizedBoxes.any((box) => box.height == 8), true);

    // Assert Container (kills 300, 8)
    final container = tester.widget<Container>(find.descendant(
      of: find.byType(Column).first,
      matching: find.byType(Container).first,
    ));
    expect(container.constraints?.minHeight, 300);
    expect(container.constraints?.maxHeight, 300);
    final boxDec = container.decoration as BoxDecoration;
    expect(boxDec.borderRadius, BorderRadius.circular(8));

    // Assert Icon size (kills 64)
    final icon = tester.widget<Icon>(find.byIcon(Icons.bar_chart));
    expect(icon.size, 64);

    expect(find.text('Chart Placeholder'), findsOneWidget);
  });
}
