/// Merge Sort เขียนเอง (หัวข้อ Sorting สัปดาห์ 5)
/// - เวลา O(n log n), ใช้พื้นที่เพิ่ม O(n)
/// - เป็น stable sort: ถ้าค่าเท่ากัน ลำดับเดิมจะไม่สลับกัน
/// [compare] คืนค่าลบ ถ้า a ควรมาก่อน b, 0 ถ้าเท่ากัน, บวก ถ้า b ควรมาก่อน
List<T> mergeSort<T>(List<T> input, int Function(T a, T b) compare) {
  if (input.length <= 1) return List<T>.of(input);

  final mid = input.length ~/ 2;
  final left = mergeSort(input.sublist(0, mid), compare);   // แบ่งครึ่งซ้าย
  final right = mergeSort(input.sublist(mid), compare);     // แบ่งครึ่งขวา
  return _merge(left, right, compare);                      // รวมกลับ
}

List<T> _merge<T>(List<T> left, List<T> right, int Function(T a, T b) compare) {
  final result = <T>[];
  var i = 0;
  var j = 0;

  while (i < left.length && j < right.length) {
    // <= 0 เพื่อให้ค่าเท่ากันเลือกฝั่งซ้ายก่อน (รักษาความ stable)
    if (compare(left[i], right[j]) <= 0) {
      result.add(left[i++]);
    } else {
      result.add(right[j++]);
    }
  }
  while (i < left.length) {
    result.add(left[i++]);
  }
  while (j < right.length) {
    result.add(right[j++]);
  }
  return result;
}
