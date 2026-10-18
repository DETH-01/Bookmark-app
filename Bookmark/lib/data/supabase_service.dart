import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/book.dart';
import 'models/cart_item.dart';
import 'models/order.dart';

/// จุดเดียวที่คุยกับ Supabase — หน้าจอเรียกผ่านคลาสนี้เท่านั้น
class SupabaseService {
  static final _db = Supabase.instance.client;

  /// เพิ่มค่าทุกครั้งที่ตะกร้าเปลี่ยน เพื่อให้หน้าตะกร้ารีโหลดเอง
  static final cartChanged = ValueNotifier<int>(0);

  // ---------- Auth ----------
  static Future<void> signIn(String email, String password) =>
      _db.auth.signInWithPassword(email: email, password: password);

  static Future<void> signUp(String email, String password) =>
      _db.auth.signUp(email: email, password: password);

  static Future<void> signOut() => _db.auth.signOut();

  static String? get currentEmail => _db.auth.currentUser?.email;

  // ---------- Books ----------
  static Future<List<Book>> fetchBooks() async {
    final rows = await _db.from('books').select().order('id');
    return (rows as List)
        .map((r) => Book.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  // ---------- Cart ----------
  static Future<List<CartItem>> fetchCart() async {
    final rows =
        await _db.from('cart_items').select('id, qty, books(*)').order('id');
    return (rows as List)
        .map((r) => CartItem.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  /// เพิ่มหนังสือลงตะกร้า ถ้ามีอยู่แล้วให้บวกจำนวนเพิ่ม
  static Future<void> addToCart(int bookId, int qty) async {
    final existing = await _db
        .from('cart_items')
        .select('qty')
        .eq('book_id', bookId)
        .maybeSingle();
    final current = existing == null ? 0 : existing['qty'] as int;
    await setCartQty(bookId, current + qty);
  }

  /// ตั้งจำนวนของหนังสือในตะกร้า (qty <= 0 คือลบออก)
  /// user_id ถูกใส่อัตโนมัติจาก auth.uid() ตามที่ตั้งไว้ใน schema.sql
  static Future<void> setCartQty(int bookId, int qty) async {
    final existing = await _db
        .from('cart_items')
        .select('id')
        .eq('book_id', bookId)
        .maybeSingle();

    if (qty <= 0) {
      if (existing != null) {
        await _db.from('cart_items').delete().eq('id', existing['id']);
      }
    } else if (existing == null) {
      await _db.from('cart_items').insert({'book_id': bookId, 'qty': qty});
    } else {
      await _db
          .from('cart_items')
          .update({'qty': qty}).eq('id', existing['id']);
    }
    cartChanged.value++;
  }

  // ---------- Orders ----------
  /// สร้างคำสั่งซื้อจากของในตะกร้า แล้วล้างตะกร้า
  /// (เวอร์ชันไม่ใช้ตาราง order_items: เก็บแค่ยอดรวมใน orders)
  static Future<void> createOrder(List<CartItem> items) async {
    final total = items.fold<double>(0, (s, i) => s + i.subtotal);

    await _db.from('orders').insert({'total': total, 'status': 'pending'});

    // RLS ทำให้ลบได้เฉพาะของเราเอง
    await _db.from('cart_items').delete().neq('id', -1);
    cartChanged.value++;
  }

  static Future<List<AppOrder>> fetchOrders() async {
    final rows = await _db
        .from('orders')
        .select('id, status, total, created_at')
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => AppOrder.fromMap(r as Map<String, dynamic>))
        .toList();
  }
}
