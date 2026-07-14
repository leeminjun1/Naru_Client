import 'package:flutter_test/flutter_test.dart';
import 'package:naru_client/features/cart/presentation/providers/cart_provider.dart';

void main() {
  group('CartProvider store boundaries', () {
    test('combines identical options from the same store', () {
      final cart = CartProvider();

      final firstAdded = cart.addItem(
        menuId: 1,
        storeId: 10,
        storeName: 'Store A',
        menuName: 'Latte',
        imagePath: 'latte.png',
        selectedSize: 'Regular',
        selectedJokbal: 'No extra',
        selectedDrink: 'No extra',
        unitPrice: 5000,
        quantity: 1,
      );
      final secondAdded = cart.addItem(
        menuId: 1,
        storeId: 10,
        storeName: 'Store A',
        menuName: 'Latte',
        imagePath: 'latte.png',
        selectedSize: 'Regular',
        selectedJokbal: 'No extra',
        selectedDrink: 'No extra',
        unitPrice: 5000,
        quantity: 2,
      );

      expect(firstAdded, isTrue);
      expect(secondAdded, isTrue);
      expect(cart.items, hasLength(1));
      expect(cart.items.single.quantity, 3);
    });

    test('rejects an item from a different store', () {
      final cart = CartProvider();

      cart.addItem(
        storeId: 10,
        storeName: 'Store A',
        menuName: 'Latte',
        imagePath: 'latte.png',
        selectedSize: 'Regular',
        selectedJokbal: 'No extra',
        selectedDrink: 'No extra',
        unitPrice: 5000,
        quantity: 1,
      );
      final added = cart.addItem(
        storeId: 20,
        storeName: 'Store B',
        menuName: 'Latte',
        imagePath: 'latte.png',
        selectedSize: 'Regular',
        selectedJokbal: 'No extra',
        selectedDrink: 'No extra',
        unitPrice: 5000,
        quantity: 1,
      );

      expect(added, isFalse);
      expect(cart.items, hasLength(1));
      expect(cart.items.single.storeId, 10);
    });
  });
}
