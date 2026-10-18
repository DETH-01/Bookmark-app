import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets/book_cover.dart';
import '../../data/models/book.dart';
import '../../data/supabase_service.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;
  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  int _qty = 1;
  bool _adding = false;

  Future<void> _addToCart() async {
    setState(() => _adding = true);
    try {
      await SupabaseService.addToCart(widget.book.id, _qty);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เพิ่ม $_qty เล่มลงตะกร้าแล้ว')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('เพิ่มลงตะกร้าไม่สำเร็จ ลองใหม่อีกครั้ง')));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.book;
    final t = Theme.of(context).textTheme;
    final inStock = b.stock > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียด')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: SizedBox(
                width: 200,
                height: 280,
                child: Hero(
                  tag: 'cover-${b.id}',
                  child: BookCover(book: b, radius: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(b.title, style: t.headlineSmall),
          const SizedBox(height: 4),
          Text(b.author ?? '-',
              style: t.titleMedium?.copyWith(
                  color: AppColors.muted, fontWeight: FontWeight.w400)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                  icon: Icons.star_rounded,
                  color: AppColors.amber,
                  text: b.rating.toStringAsFixed(1)),
              _Pill(
                  icon: Icons.inventory_2_outlined,
                  color: inStock ? AppColors.mint : const Color(0xFFFF6B6B),
                  text: inStock ? 'คงเหลือ ${b.stock} เล่ม' : 'สินค้าหมด'),
              if (b.isbn != null)
                _Pill(
                    icon: Icons.tag,
                    color: AppColors.muted,
                    text: 'ISBN ${b.isbn}'),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Text('จำนวน', style: TextStyle(color: AppColors.muted)),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed:
                          _qty > 1 ? () => setState(() => _qty--) : null,
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text('$_qty',
                          textAlign: TextAlign.center, style: t.titleMedium),
                    ),
                    IconButton(
                      onPressed:
                          _qty < b.stock ? () => setState(() => _qty++) : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ราคารวม',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.muted)),
                  Text('฿${(b.price * _qty).toStringAsFixed(0)}',
                      style: t.titleLarge?.copyWith(
                          color: AppColors.amber,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FilledButton.icon(
                  onPressed: (inStock && !_adding) ? _addToCart : null,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(_adding
                      ? 'กำลังเพิ่ม...'
                      : (inStock ? 'เพิ่มลงตะกร้า' : 'สินค้าหมด')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _Pill({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
