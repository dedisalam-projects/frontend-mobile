import 'package:flutter_test/flutter_test.dart';
import 'package:dash/services/dashboard_service.dart';
import 'package:dash/models/product.dart';

void main() {
  group('DashboardService Tests', () {
    test('getRecentSales should return a list of Products with correct data', () async {
      final stopwatch = Stopwatch()..start();
      final products = await DashboardService.getRecentSales();
      stopwatch.stop();
      
      // Ensure the delay actually happens (at least 100ms) to kill the negative duration mutation
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      
      expect(products, isA<List<Product>>());
      expect(products.length, 5);
      
      // Test product 1
      expect(products[0].id, '1000');
      expect(products[0].code, 'f230fh0g3');
      expect(products[0].name, 'Bamboo Watch');
      expect(products[0].description, 'Product Description');
      expect(products[0].image, 'bamboo-watch.jpg');
      expect(products[0].price, 65);
      expect(products[0].category, 'Accessories');
      expect(products[0].quantity, 24);
      expect(products[0].inventoryStatus, 'INSTOCK');
      expect(products[0].rating, 5);

      // Test product 2
      expect(products[1].id, '1001');
      expect(products[1].image, 'black-watch.jpg');
      expect(products[1].price, 72);
      expect(products[1].quantity, 61);

      // Test product 3
      expect(products[2].image, 'blue-band.jpg');
      expect(products[2].price, 79);

      // Test product 4
      expect(products[3].name, 'Blue T-Shirt');
      expect(products[3].image, 'blue-t-shirt.jpg');
      expect(products[3].price, 29);
      expect(products[3].quantity, 25);

      // Test product 5
      expect(products[4].price, 15);
      expect(products[4].quantity, 73);
    });

    test('getBestSelling should return a list of Products with correct data', () async {
      final stopwatch = Stopwatch()..start();
      final products = await DashboardService.getBestSelling();
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      
      expect(products, isA<List<Product>>());
      expect(products.length, 2);
      
      // Test product 1
      expect(products[0].id, '1011');
      expect(products[0].name, 'Green Earbuds');
      expect(products[0].image, 'green-earbuds.jpg');
      expect(products[0].price, 89);
      expect(products[0].quantity, 23);

      // Test product 2
      expect(products[1].name, 'Green T-Shirt');
      expect(products[1].image, 'green-t-shirt.jpg');
      expect(products[1].price, 49);
      expect(products[1].quantity, 74);
    });
  });
}
