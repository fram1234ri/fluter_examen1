/// Modelo de Categoría
class Category {
  final int id;
  final String nombre;

  Category({required this.id, required this.nombre});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id:
          json['idCategoria'] is int
              ? json['idCategoria']
              : int.tryParse(json['idCategoria'].toString()) ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }

  // 🔹 Sobreescribimos == y hashCode para que Flutter
  //    compare categorías por id en lugar de por referencia.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
