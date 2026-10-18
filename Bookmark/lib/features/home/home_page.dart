import 'package:flutter/material.dart';

import '../../core/algo/merge_sort.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/book_cover.dart';
import '../../data/models/book.dart';
import '../../data/supabase_service.dart';
import 'book_detail_page.dart';

enum SortOption {
  titleAsc('ชื่อ ก-ฮ'),
  priceAsc('ราคาต่ำ → สูง'),
  priceDesc('ราคาสูง → ต่ำ'),
  ratingDesc('เรตติ้งสูงสุด');

  final String label;
  const SortOption(this.label);

  /// ฟังก์ชันเปรียบเทียบที่ส่งให้ mergeSort
  int compare(Book a, Book b) {
    switch (this) {
      case SortOption.titleAsc:
        return a.title.compareTo(b.title);
      case SortOption.priceAsc:
        return a.price.compareTo(b.price);
      case SortOption.priceDesc:
        return b.price.compareTo(a.price);
      case SortOption.ratingDesc:
        return b.rating.compareTo(a.rating);
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Book>> _books = SupabaseService.fetchBooks();
  final _search = TextEditingController();
  String _query = '';
  SortOption _sort = SortOption.titleAsc;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() => setState(() => _books = SupabaseService.fetchBooks());

  /// กรองด้วยคำค้นหา แล้วเรียงด้วย Merge Sort ที่เขียนเอง
  List<Book> _visible(List<Book> all) {
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all
            .where((b) =>
                b.title.toLowerCase().contains(q) ||
                (b.author ?? '').toLowerCase().contains(q))
            .toList();
    return mergeSort(filtered, _sort.compare);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 34),
            SizedBox(width: 10),
            Text('Bookmark'),
          ],
        ),
      ),
      body: FutureBuilder<List<Book>>(
        future: _books,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('โหลดรายการหนังสือไม่สำเร็จ'),
                const SizedBox(height: 8),
                TextButton(onPressed: _reload, child: const Text('ลองใหม่')),
              ]),
            );
          }
          final all = snap.data!;
          if (all.isEmpty) {
            return const Center(
                child: Text('ยังไม่มีหนังสือ ให้รัน supabase/schema.sql ก่อน'));
          }
          final books = _visible(all);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'ค้นหาชื่อหนังสือหรือผู้แต่ง',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: SortOption.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final o = SortOption.values[i];
                    final selected = o == _sort;
                    return ChoiceChip(
                      label: Text(o.label),
                      selected: selected,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _sort = o),
                      selectedColor: AppColors.amber,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                          color:
                              selected ? AppColors.amber : AppColors.border),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.bg : AppColors.text,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('พบ ${books.length} เล่ม',
                      style: const TextStyle(color: AppColors.muted)),
                ),
              ),
              Expanded(
                child: books.isEmpty
                    ? const Center(child: Text('ไม่พบหนังสือที่ค้นหา'))
                    : RefreshIndicator(
                        onRefresh: () async => _reload(),
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 230,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.54,
                          ),
                          itemCount: books.length,
                          itemBuilder: (_, i) => _BookCard(book: books[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookDetailPage(book: book)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'cover-${book.id}',
                      child: BookCover(book: book, radius: 0),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.bg.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.amber),
                          const SizedBox(width: 3),
                          Text(book.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleSmall),
                  const SizedBox(height: 2),
                  Text(book.author ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('฿${book.price.toStringAsFixed(0)}',
                          style: t.titleMedium?.copyWith(
                              color: AppColors.amber,
                              fontWeight: FontWeight.w700)),
                      const Spacer(),
                      if (book.stock <= 0)
                        const Text('หมด',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFFFF6B6B))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
