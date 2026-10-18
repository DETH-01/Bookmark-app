class Book {
  final int id;
  final String? isbn;
  final String title;
  final String? author;
  final double price;
  final double rating;
  final int stock;
  final String? coverUrl;

  const Book({
    required this.id,
    this.isbn,
    required this.title,
    this.author,
    required this.price,
    required this.rating,
    required this.stock,
    this.coverUrl,
  });

  factory Book.fromMap(Map<String, dynamic> m) => Book(
        id: m['id'] as int,
        isbn: m['isbn'] as String?,
        title: m['title'] as String,
        author: m['author'] as String?,
        price: (m['price'] as num).toDouble(),
        rating: ((m['rating'] ?? 0) as num).toDouble(),
        stock: (m['stock'] ?? 0) as int,
        coverUrl: m['cover_url'] as String?,
      );
}
