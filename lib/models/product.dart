/// Modelo de Producto
class Product {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int idCategoria;
  final String? imagen;
  final String? categoria;

  Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.idCategoria,
    this.imagen,
    this.categoria,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // 🔹 Manejo seguro si id viene como string
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id'].toString()) ?? 0,

      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',

      // 🔹 Manejo seguro si precio viene como string
      precio:
          (json['precio'] is num)
              ? (json['precio'] as num).toDouble()
              : double.tryParse(json['precio'].toString()) ?? 0,

      // 🔹 Manejo seguro si idCategoria viene como string
      idCategoria:
          json['idCategoria'] is int
              ? json['idCategoria']
              : int.tryParse(json['idCategoria'].toString()) ?? 0,

      imagen: json['imagen'],
      categoria: json['categoria'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nombre": nombre,
      "descripcion": descripcion,
      "precio": precio,
      "idCategoria": idCategoria,
    };
  }
}
