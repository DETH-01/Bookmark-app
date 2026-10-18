class OrderLine {
  final String title;
  final int qty;
  final double price;
  const OrderLine(this.title, this.qty, this.price);
}

class AppOrder {
  final int id;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<OrderLine> lines;

  const AppOrder({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.lines,
  });

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'shipped':
        return 'จัดส่งแล้ว';
      case 'done':
        return 'สำเร็จ';
      default:
        return status;
    }
  }

  factory AppOrder.fromMap(Map<String, dynamic> m) {
    final items = (m['order_items'] as List? ?? []).map((e) {
      final row = e as Map<String, dynamic>;
      final book = row['books'] as Map<String, dynamic>?;
      return OrderLine(
        (book?['title'] ?? 'ไม่ทราบชื่อ') as String,
        row['qty'] as int,
        (row['price'] as num).toDouble(),
      );
    }).toList();

    return AppOrder(
      id: m['id'] as int,
      status: (m['status'] ?? 'pending') as String,
      total: ((m['total'] ?? 0) as num).toDouble(),
      createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
      lines: items,
    );
  }
}
