import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dash/screens/dashboard_screen.dart';
import 'package:dash/widgets/stats_widget.dart';
import 'package:dash/widgets/recent_sales_widget.dart';
import 'package:dash/widgets/best_selling_widget.dart';
import 'package:dash/widgets/revenue_stream_widget.dart';
import 'package:dash/widgets/notifications_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'auth_token': 'fake-token'});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/login': (context) => const Scaffold(body: Text('Login Screen')),
      },
      initialRoute: '/dashboard',
    );
  }

  void setDisplaySize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('DashboardScreen', () {
    testWidgets('renders Dashboard title, padding, spacing, and widgets correctly', (WidgetTester tester) async {
      setDisplaySize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      
      // Assert Scaffold background color
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, Colors.grey.shade50);

      // Assert SingleChildScrollView padding (kills 16.0 mutation)
      expect(find.byWidgetPredicate((w) => w is SingleChildScrollView && w.padding == const EdgeInsets.all(16.0)), findsWidgets);

      // Assert SizedBox heights
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(sizedBoxes.where((box) => box.height == 16).length, greaterThanOrEqualTo(4));
      expect(sizedBoxes.where((box) => box.width == 16).length, greaterThanOrEqualTo(1));

      // Assert all widgets are present
      expect(find.byType(StatsWidget), findsOneWidget);
      expect(find.byType(RecentSalesWidget), findsOneWidget);
      expect(find.byType(BestSellingWidget), findsOneWidget);
      expect(find.byType(RevenueStreamWidget), findsOneWidget);
      expect(find.byType(NotificationsWidget), findsOneWidget);
    });

    testWidgets('logout button clears token and navigates to login', (WidgetTester tester) async {
      setDisplaySize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
      
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}
