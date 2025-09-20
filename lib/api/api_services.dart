import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/category.dart';
import '../models/product.dart';

/// Servicio para interactuar con la API en PHP + MySQL.
/// Compatible con Flutter Web y Mobile/Desktop.
class ApiService {
  final String baseUrl;
  ApiService(this.baseUrl);

  // ======================
  // 🔹 Categorías
  // ======================

  Future<List<Category>> getCategories() async {
    final res = await http.get(Uri.parse('$baseUrl/categorias.php'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Category.fromJson(e)).toList();
    }
    throw Exception('Error cargando categorías');
  }

  // ======================
  // 🔹 Productos
  // ======================

  Future<List<Product>> getProducts({
    String? search,
    int? idCategoria,
    int page = 1,
    int limit = 20,
  }) async {
    var url = "$baseUrl/productos.php?page=$page&limit=$limit";
    if (search != null && search.isNotEmpty) url += "&search=$search";
    if (idCategoria != null) url += "&idCategoria=$idCategoria";

    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }
    throw Exception('Error cargando productos');
  }

  /// 🔹 Crear producto (con o sin imagen)
  Future<int> addProduct({
    required String nombre,
    required String descripcion,
    required double precio,
    required int idCategoria,
    XFile? imagen,
  }) async {
    var uri = Uri.parse('$baseUrl/productos.php');

    if (imagen != null) {
      // Usar multipart si hay imagen
      var request = http.MultipartRequest('POST', uri);
      request.fields['multipart'] = '1';
      request.fields['nombre'] = nombre;
      request.fields['descripcion'] = descripcion;
      request.fields['precio'] = precio.toString();
      request.fields['idCategoria'] = idCategoria.toString();

      if (kIsWeb) {
        // En Web no hay path real → usar bytes
        final bytes = await imagen.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('imagen', bytes, filename: imagen.name),
        );
      } else {
        // En Mobile/Desktop sí hay path
        request.files.add(
          await http.MultipartFile.fromPath('imagen', imagen.path),
        );
      }

      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'];
      } else {
        throw Exception("Error creando producto: ${response.body}");
      }
    } else {
      // Enviar como JSON si no hay imagen
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombre,
          "descripcion": descripcion,
          "precio": precio,
          "idCategoria": idCategoria,
        }),
      );
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return data['id'];
      }
      throw Exception("Error creando producto: ${res.body}");
    }
  }

  /// 🔹 Actualizar producto (con o sin imagen)
  Future<void> updateProduct({
    required int id,
    required String nombre,
    required String descripcion,
    required double precio,
    required int idCategoria,
    XFile? imagen,
  }) async {
    var uri = Uri.parse('$baseUrl/productos.php?id=$id');

    if (imagen != null) {
      var request = http.MultipartRequest('PUT', uri);
      request.fields['multipart'] = '1';
      request.fields['nombre'] = nombre;
      request.fields['descripcion'] = descripcion;
      request.fields['precio'] = precio.toString();
      request.fields['idCategoria'] = idCategoria.toString();

      if (kIsWeb) {
        final bytes = await imagen.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('imagen', bytes, filename: imagen.name),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('imagen', imagen.path),
        );
      }

      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw Exception("Error actualizando producto: ${response.body}");
      }
    } else {
      final res = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombre,
          "descripcion": descripcion,
          "precio": precio,
          "idCategoria": idCategoria,
        }),
      );

      if (res.statusCode != 200) {
        throw Exception("Error actualizando producto: ${res.body}");
      }
    }
  }

  /// 🔹 Eliminar producto
  Future<void> deleteProduct(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/productos.php?id=$id'));
    if (res.statusCode != 200) {
      throw Exception('No se pudo eliminar producto');
    }
  }
}
