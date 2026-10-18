import 'package:flutter/material.dart';

import '../../core/ds/stack.dart';
import '../../core/theme.dart';
import '../../core/widgets/book_cover.dart';
import '../../data/models/cart_item.dart';
import '../../data/supabase_service.dart';

/// การกระทำหนึ่งครั้งในตะกร้า เก็บ "จำนวนก่อนแก้" ไว้ใช้ย้อนกลับ
class _CartAction {
  final int bookId;
  final String title;
  final int previousQty;
  const _CartAction(this.bookId, this.title, this.previousQty);
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _items = [];
  bool _loading = true;
  bool _error = false;
  bool _busy = false;

  /// Stack เก็บประวัติการแก้ตะกร้า: Undo = pop ตัวล่าสุดออกมาย้อนกลับ
  final _undo = LifoStack<_CartAction>();

  @override
  void initState() {
    super.initState();
    SupabaseService.cartChanged.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    SupabaseService.cartChanged.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await SupabaseService.fetchCart();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _error = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  double get _total => _items.fold(0.0, (s, i) => s + i.subtotal);

  void _toast(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _change(CartItem item, int newQty) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      _undo.push(_CartAction(item.book.id, item.book.title, item.qty));
      await SupabaseService.setCartQty(item.book.id, newQty);
    } catch (_) {
      _undo.pop(); // แก้ไม่สำเร็จ เอาประวัติที่เพิ่งเก็บออก
      _toast('แก้ตะกร้าไม่สำเร็จ ลองใหม่อีกครั้ง');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _undoLast() async {
    if (_busy) return;
    final action = _undo.pop();
    if (action == null) return;
    setState(() => _busy = true);
    try {
      await SupabaseService.setCartQty(action.bookId, action.previousQty);
      _toast('ย้อนกลับ: ${action.title}');
    } catch (_) {
      _undo.push(action); // ย้อนไม่สำเร็จ ใส่กลับเข้า stack
      _toast('ย้อนกลับไม่สำเร็จ ลองใหม่อีกครั้ง');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการสั่งซื้อ'),
        content: Text(
            '${_items.length} รายการ รวม ฿${_total.toStringAsFixed(0)}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก')),
          FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('สั่งซื้อ')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      await SupabaseService.createOrder(_items);
      _undo.clear(); // สั่งซื้อแล้ว ย้อนกลับไม่ได้
      _toast('สั่งซื้อสำเร็จ ดูได้ที่โปรไฟล์ > ประวัติคำสั่งซื้อ');
    } catch (_) {
      _toast('สั่งซื้อไม่สำเร็จ ลองใหม่อีกครั้ง');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตะกร้าสินค้า'),
        actions: [
          IconButton(
            tooltip: 'ย้อนกลับการแก้ไขล่าสุด',
            onPressed: (_undo.isEmpty || _busy) ? null : _undoLast,
            icon: Badge(
              isLabelVisible: _undo.isNotEmpty,
              label: Text('${_undo.length}'),
              child: const Icon(Icons.undo),
            ),
          ),
        ],
      ),
      body: _body(),
      bottomNavigationBar: _items.isEmpty ? null : _checkoutBar(),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('โหลดตะกร้าไม่สำเร็จ'),
          TextButton(onPressed: _load, child: const Text('ลองใหม่')),
        ]),
      );
    }
    if (_items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_bag_outlined,
                  size: 64, color: AppColors.amber),
              SizedBox(height: 12),
              Text('ตะกร้ายังว่างอยู่', textAlign: TextAlign.center),
              SizedBox(height: 4),
              Text('เลือกหนังสือที่หน้าแรกแล้วกดเพิ่มลงตะกร้าได้เลย',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _items.length,
      itemBuilder: (_, i) => _CartTile(
        item: _items[i],
        busy: _busy,
        onChange: (q) => _change(_items[i], q),
      ),
    );
  }

  Widget _checkoutBar() {
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('รวมทั้งหมด'),
                  Text('฿${_total.toStringAsFixed(0)}',
                      style: t.titleLarge?.copyWith(
                          color: AppColors.amber, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              child: FilledButton(
                onPressed: _busy ? null : _checkout,
                child: const Text('สั่งซื้อ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  final bool busy;
  final ValueChanged<int> onChange;
  const _CartTile(
      {required this.item, required this.busy, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final b = item.book;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 72,
              child: BookCover(book: b, radius: 8),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.title,
                      style:
                          t.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('฿${b.price.toStringAsFixed(0)} x ${item.qty} = '
                      '฿${item.subtotal.toStringAsFixed(0)}'),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed:
                            busy ? null : () => onChange(item.qty - 1),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${item.qty}', style: t.titleMedium),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: (busy || item.qty >= b.stock)
                            ? null
                            : () => onChange(item.qty + 1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'ลบออกจากตะกร้า',
              onPressed: busy ? null : () => onChange(0),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
