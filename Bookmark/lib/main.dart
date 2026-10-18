import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config.dart';
import 'core/theme.dart';
import 'features/auth/login_page.dart';
import 'features/shell/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ถ้า widget ไหนพัง ให้แสดงข้อความ error บนจอ แทนที่จะเป็นจอเทา/ดำ
  ErrorWidget.builder = (details) => Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.white,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(details.exceptionAsString()),
            ),
          ),
        ),
      );

  String? startupError;
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    ).timeout(const Duration(seconds: 15));
  } catch (e, st) {
    startupError = '$e\n\n$st';
  }

  runApp(startupError == null
      ? const BookstoreApp()
      : ErrorApp(message: startupError));
}

/// แสดงเมื่อเริ่มต้นแอพ (เชื่อมต่อ Supabase) ไม่สำเร็จ
class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText('เริ่มแอพไม่สำเร็จ\n\n$message'),
          ),
        ),
      ),
    );
  }
}

class BookstoreApp extends StatelessWidget {
  const BookstoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookmark',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const AuthGate(),
    );
  }
}

/// ล็อกอินแล้ว -> เข้าแอพ, ยังไม่ล็อกอิน -> หน้า Login
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, _) {
        final session = Supabase.instance.client.auth.currentSession;
        return session == null ? const LoginPage() : const AppShell();
      },
    );
  }
}