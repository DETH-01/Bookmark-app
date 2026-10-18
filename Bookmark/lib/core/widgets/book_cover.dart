import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/book.dart';
import '../theme.dart';

/// ปกหนังสือ: ถ้ามี cover_url ใช้รูปจริง ถ้าไม่มีสร้างปกสีไล่เฉดจากชื่อหนังสือ
/// ขนาดเต็มพื้นที่ที่แม่กำหนด (ใส่ใน SizedBox / Expanded)
class BookCover extends StatelessWidget {
  final Book book;
  final double radius;
  const BookCover({super.key, required this.book, this.radius = 12});

  static const _palettes = [
    [Color(0xFF1F4E8C), Color(0xFF0F2547)],
    [Color(0xFF0E6B73), Color(0xFF0A2F36)],
    [Color(0xFF8A3340), Color(0xFF3B141B)],
    [Color(0xFF2F7A57), Color(0xFF12331F)],
    [Color(0xFF9A5B2E), Color(0xFF3F220F)],
    [Color(0xFF4A3F8F), Color(0xFF1C1744)],
  ];

  @override
  Widget build(BuildContext context) {
    final url = book.coverUrl;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _generated(),
        ),
      );
    }
    return _generated();
  }

  Widget _generated() {
    final colors = _palettes[book.id.abs() % _palettes.length];
    final initial = book.title.isEmpty
        ? '?'
        : String.fromCharCode(book.title.runes.first);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: LayoutBuilder(builder: (context, c) {
          final w = c.hasBoundedWidth ? c.maxWidth : 120.0;
          final titleSize = (w * 0.085).clamp(9.0, 22.0).toDouble();
          return Stack(
            children: [
              Positioned(
                right: -w * 0.08,
                bottom: -w * 0.2,
                child: Text(
                  initial,
                  style: GoogleFonts.prompt(
                    fontSize: w * 0.85,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: w * 0.12,
                child: Container(
                  width: w * 0.09,
                  height: w * 0.26,
                  decoration: const BoxDecoration(
                    color: AppColors.amber,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(3)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(w * 0.1),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    book.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.prompt(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
