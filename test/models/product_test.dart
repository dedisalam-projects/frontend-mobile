import 'package:flutter_test/flutter_test.dart';
import 'package:dash/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('should create a Product instance correctly', () {
      final product = Product(
        id: '1',
        code: 'A123',
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        quantity: 10,
        inventoryStatus: 'INSTOCK',
        category: 'Electronics',
        image: 'test.jpg',
        rating: 4.5,
      );

      expect(product.id, '1');
      expect(product.code, 'A123');
      expect(product.name, 'Test Product');
      expect(product.description, 'Test Description');
      expect(product.price, 99.99);
      expect(product.quantity, 10);
      expect(product.inventoryStatus, 'INSTOCK');
      expect(product.category, 'Electronics');
      expect(product.image, 'test.jpg');
      expect(product.rating, 4.5);
    });
  });
}
