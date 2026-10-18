import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// สีทั้งหมดของแอพอยู่ที่นี่ที่เดียว (ธีมมืด + สีเน้นเหลืองอำพัน)
class AppColors {
  static const bg = Color(0xFF0B1220);          // พื้นหลังหลัก
  static const surface = Color(0xFF121B2E);     // การ์ด / แถบล่าง
  static const surfaceHigh = Color(0xFF1A2740); // ชั้นที่ลอยกว่า
  static const border = Color(0xFF24334F);      // เส้นขอบ
  static const text = Color(0xFFE8EEF7);        // ตัวอักษรหลัก
  static const muted = Color(0xFF8FA0BA);       // ตัวอักษรรอง
  static const amber = Color(0xFFFFB020);       // สีเน้น / ปุ่มหลัก (ริบบิ้น)
  static const mint = Color(0xFF3DDBB0);        // สีเน้นรอง

  // ชื่อเดิมที่ไฟล์เก่าอาจยังอ้างถึง
  static const ink = bg;
  static const teal = amber;
  static const ribbon = amber;
  static const paper = bg;
  static const card = surface;
}

OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.amber,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.amber,
    onPrimary: AppColors.bg,
    secondary: AppColors.mint,
    onSecondary: AppColors.bg,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    outline: AppColors.border,
    error: const Color(0xFFFF6B6B),
  );

  final base = ThemeData(colorScheme: scheme, useMaterial3: true);

  // เนื้อความใช้ Noto Sans Thai, หัวข้อใช้ Prompt ให้ดูโมเดิร์น
  final body = GoogleFonts.notoSansThaiTextTheme(base.textTheme)
      .apply(bodyColor: AppColors.text, displayColor: AppColors.text);
  TextStyle head(TextStyle? s, FontWeight w) =>
      GoogleFonts.prompt(textStyle: s, fontWeight: w, color: AppColors.text);
  final text = body.copyWith(
    headlineMedium: head(body.headlineMedium, FontWeight.w700),
    headlineSmall: head(body.headlineSmall, FontWeight.w700),
    titleLarge: head(body.titleLarge, FontWeight.w600),
    titleMedium: head(body.titleMedium, FontWeight.w600),
    titleSmall: head(body.titleSmall, FontWeight.w600),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.bg,
        disabledBackgroundColor: AppColors.surfaceHigh,
        disabledForegroundColor: AppColors.muted,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle:
            GoogleFonts.prompt(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.border),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.amber),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.muted),
      prefixIconColor: AppColors.muted,
      suffixIconColor: AppColors.muted,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: _border(AppColors.border),
      enabledBorder: _border(AppColors.border),
      focusedBorder: _border(AppColors.amber, 1.5),
      errorBorder: _border(const Color(0xFFFF6B6B)),
      focusedErrorBorder: _border(const Color(0xFFFF6B6B), 1.5),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.amber.withValues(alpha: 0.16),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? AppColors.amber
              : AppColors.muted)),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => GoogleFonts.prompt(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: s.contains(WidgetState.selected)
              ? AppColors.amber
              : AppColors.muted)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: const TextStyle(color: AppColors.text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
  );
}
