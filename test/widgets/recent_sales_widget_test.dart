import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dash/widgets/recent_sales_widget.dart';
import 'package:dash/models/product.dart';

void main() {
  testWidgets('RecentSalesWidget renders correctly with layout styling and data', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: RecentSalesWidget()),
      ),
    ));

    // Initially loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the future to complete
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Recent Sales'), findsOneWidget);
    
    // Check Title styling (kills fontSize: 20)
    final titleText = tester.widget<Text>(find.text('Recent Sales'));
    expect(titleText.style?.fontSize, 20);

    // Assert Card styling (kills elevation: 0, borderRadius: 12, alpha: 0.2)
    final card = tester.widget<Card>(find.byType(Card).first);
    expect(card.elevation, 0);
    final shape = card.shape as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(12));
    expect(shape.side.color.a, closeTo(0.2, 0.01));

    // Assert padding (kills 16.0)
    expect(find.byWidgetPredicate((w) => w is Padding && w.padding == const EdgeInsets.all(16.0)), findsWidgets);

    // Assert SizedBox height (kills 16)
    final sizedBox = tester.widget<SizedBox>(find.descendant(
      of: find.byType(Column).first,
      matching: find.byType(SizedBox).first,
    ));
    expect(sizedBox.height, 16);

    // Assert data items
    expect(find.text('Bamboo Watch'), findsOneWidget);
    
    // Assert subtitle formatting (kills toStringAsFixed(2))
    expect(find.text('\$65.00'), findsOneWidget); // Assuming 65.0 is the mock price

    // Inspect first ListTile
    final listTile = tester.widget<ListTile>(find.byType(ListTile).first);
    expect(listTile.contentPadding, EdgeInsets.zero);

    // Inspect ListView
    final listView = tester.widget<ListView>(find.byType(ListView).first);
    expect(listView.shrinkWrap, isTrue);
    expect(listView.physics, isA<NeverScrollableScrollPhysics>());
    
    // Inspect Dividers (kills separatorBuilder mutation)
    expect(find.byType(Divider), findsWidgets);

    // Inspect leading Container (kills 50, 50, 8)
    final container = tester.widget<Container>(find.descendant(
      of: find.byType(ListTile).first,
      matching: find.byType(Container).first,
    ));
    expect(container.constraints?.maxWidth, 50);
    expect(container.constraints?.maxHeight, 50);
    final boxDec = container.decoration as BoxDecoration;
    expect(boxDec.borderRadius, BorderRadius.circular(8));
    expect(boxDec.color, Colors.grey.shade200); // Kills color mutation

    // Check Icon color
    final icon = tester.widget<Icon>(find.descendant(
      of: find.byWidget(container),
      matching: find.byType(Icon).first,
    ));
    expect(icon.color, Colors.grey);

    expect(find.byIcon(Icons.search), findsWidgets);
    await tester.tap(find.byIcon(Icons.search).first);
    await tester.pump();
    await tester.pumpWidget(Container());
  });


  testWidgets('RecentSalesWidget renders correctly with empty data', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: RecentSalesWidget(
            productsFutureOverride: Future.value([]),
          ),
        ),
      ),
    ));

    await tester.pump();
    expect(find.text('No recent sales.'), findsOneWidget);
    await tester.pumpWidget(Container());
  });

  testWidgets('RecentSalesWidget renders error state', (WidgetTester tester) async {
    final errorFuture = Future<List<Product>>.error('Test error');
    errorFuture.ignore();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: RecentSalesWidget(
            productsFutureOverride: errorFuture,
          ),
        ),
      ),
    ));

    await tester.pump();
    expect(find.text('Error: Test error'), findsOneWidget);
    await tester.pumpWidget(Container());
  });
}



