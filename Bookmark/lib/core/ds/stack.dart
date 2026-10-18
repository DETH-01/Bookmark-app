/// Stack (LIFO: เข้าหลังออกก่อน) เขียนเอง — หัวข้อสัปดาห์ 7
/// ตั้งชื่อ LifoStack เพื่อไม่ให้ชนกับ widget ชื่อ Stack ของ Flutter
/// push / pop / peek ทุกอย่างใช้เวลา O(1)
class LifoStack<T> {
  final List<T> _items = [];

  void push(T value) => _items.add(value);

  /// เอาตัวบนสุดออก (คืน null ถ้า stack ว่าง)
  T? pop() => _items.isEmpty ? null : _items.removeLast();

  /// ดูตัวบนสุดโดยไม่เอาออก
  T? get peek => _items.isEmpty ? null : _items.last;

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  int get length => _items.length;

  void clear() => _items.clear();
}
