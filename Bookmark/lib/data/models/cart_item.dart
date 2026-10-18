import 'book.dart';

class CartItem {
  final int id;
  final int qty;
  final Book book;

  const CartItem({required this.id, required this.qty, required this.book});

  double get subtotal => book.price * qty;

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
        id: m['id'] as int,
        qty: m['qty'] as int,
        book: Book.fromMap(m['books'] as Map<String, dynamic>),
      );
}
