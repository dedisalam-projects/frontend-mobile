import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dash/widgets/best_selling_widget.dart';

void main() {
  testWidgets('BestSellingWidget renders correctly with layout styling', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: BestSellingWidget()),
      ),
    ));

    expect(find.text('Best Selling Products'), findsOneWidget);
    final titleText = tester.widget<Text>(find.text('Best Selling Products'));
    expect(titleText.style?.fontSize, 20);

    // Assert Card styling (kills elevation: 0, borderRadius: 12, alpha: 0.2)
    final card = tester.widget<Card>(find.byType(Card).first);
    expect(card.elevation, 0);
    final shape = card.shape as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(12));
    expect(shape.side.color.a, closeTo(0.2, 0.01));

    // Assert padding (kills 16.0)
    expect(find.byWidgetPredicate((w) => w is Padding && w.padding == const EdgeInsets.all(16.0)), findsWidgets);

    // Inspect first item (_buildBestSellingItem)
    expect(find.text('Space T-Shirt'), findsOneWidget);
    
    // Category font size (kills 12)
    final categoryText = tester.widget<Text>(find.text('Clothing').first);
    expect(categoryText.style?.fontSize, 12);

    // Outer Padding (kills bottom: 16.0)
    expect(find.byWidgetPredicate((w) => w is Padding && w.padding == const EdgeInsets.only(bottom: 16.0)), findsWidgets);

    // Assert containers (kills 100, 8, 4)
    final row = find.ancestor(
      of: find.text('Space T-Shirt'),
      matching: find.byType(Row),
    ).first;

    final containers = tester.widgetList<Container>(find.descendant(
      of: row,
      matching: find.byType(Container),
    )).toList();
    
    final bgContainer = containers.first;
    expect(bgContainer.constraints?.maxWidth, 100);
    expect(bgContainer.constraints?.maxHeight, 8);
    final bgDec = bgContainer.decoration as BoxDecoration;
    expect(bgDec.borderRadius, BorderRadius.circular(4));

    final fgContainer = containers.last;
    expect(fgContainer.constraints?.maxWidth, 100 * (50 / 100)); // 50%
    expect(fgContainer.constraints?.maxHeight, 8);
    final fgDec = fgContainer.decoration as BoxDecoration;
    expect(fgDec.borderRadius, BorderRadius.circular(4));

    // SizedBox width (kills 8)
    final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    expect(sizedBoxes.any((box) => box.width == 8), true);
    expect(sizedBoxes.any((box) => box.height == 16), true);

    expect(find.text('%50'), findsOneWidget);
    expect(find.text('%40'), findsOneWidget);
    expect(find.text('Robots T-Shirt'), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pump();

  });
}

