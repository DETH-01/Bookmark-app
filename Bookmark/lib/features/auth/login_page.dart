import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme.dart';
import '../../core/widgets/app_logo.dart';
import '../../data/supabase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final email = _email.text.trim();
      final pw = _password.text;
      if (_isRegister) {
        await SupabaseService.signUp(email, pw);
      } else {
        await SupabaseService.signIn(email, pw);
      }
    } on AuthException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast('เชื่อมต่อไม่ได้ ตรวจสอบอินเทอร์เน็ตแล้วลองใหม่');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.75),
            radius: 1.1,
            colors: [Color(0xFF1A3158), AppColors.bg],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: AppLogo(size: 96)),
                      const SizedBox(height: 20),
                      Text('Bookmark',
                          textAlign: TextAlign.center,
                          style: t.headlineSmall),
                      const SizedBox(height: 6),
                      Text(
                          _isRegister
                              ? 'สร้างบัญชีใหม่เพื่อเริ่มช้อป'
                              : 'เข้าสู่ระบบเพื่อเลือกอ่านเล่มที่ใช่',
                          textAlign: TextAlign.center,
                          style: t.bodyMedium
                              ?.copyWith(color: AppColors.muted)),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'อีเมล',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'กรอกอีเมลให้ถูกต้อง'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'รหัสผ่าน',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'รหัสผ่านอย่างน้อย 6 ตัวอักษร'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: AppColors.bg))
                            : Text(
                                _isRegister ? 'สมัครสมาชิก' : 'เข้าสู่ระบบ'),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () =>
                                setState(() => _isRegister = !_isRegister),
                        child: Text(_isRegister
                            ? 'มีบัญชีแล้ว? เข้าสู่ระบบ'
                            : 'ยังไม่มีบัญชี? สมัครสมาชิก'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
