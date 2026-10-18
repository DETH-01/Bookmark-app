import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/order.dart';
import '../../data/supabase_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<AppOrder>> _orders = SupabaseService.fetchOrders();

  String _date(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('ประวัติคำสั่งซื้อ')),
      body: FutureBuilder<List<AppOrder>>(
        future: _orders,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('โหลดประวัติคำสั่งซื้อไม่สำเร็จ'),
                TextButton(
                    onPressed: () => setState(
                        () => _orders = SupabaseService.fetchOrders()),
                    child: const Text('ลองใหม่')),
              ]),
            );
          }
          final orders = snap.data!;
          if (orders.isEmpty) {
            return const Center(child: Text('ยังไม่มีคำสั่งซื้อ'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final o = orders[i];
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  title: Text('คำสั่งซื้อ #${o.id}',
                      style: t.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text('${_date(o.createdAt)}  •  ${o.statusLabel}'),
                  trailing: Text('฿${o.total.toStringAsFixed(0)}',
                      style: t.titleMedium?.copyWith(
                          color: AppColors.teal, fontWeight: FontWeight.w700)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
