// ✅ Importaciones necesarias
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_services.dart';
import '../models/category.dart';
import '../models/product.dart';

/// Pantalla para crear o editar productos (estilo Anime Dark)
class ProductFormScreen extends StatefulWidget {
  final ApiService api;
  final Product? producto;

  const ProductFormScreen({super.key, required this.api, this.producto});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();

  Category? catSel;
  List<Category> categorias = [];
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    if (widget.producto != null) {
      _nombreCtrl.text = widget.producto!.nombre;
      _descCtrl.text = widget.producto!.descripcion;
      _precioCtrl.text = widget.producto!.precio.toString();
      catSel =
          widget.producto!.idCategoria != null
              ? Category(
                id: widget.producto!.idCategoria!,
                nombre: widget.producto!.categoria ?? "",
              )
              : null;
    }
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    final cats = await widget.api.getCategories();
    setState(() {
      categorias = cats;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _pickedImage = img);
  }

  Widget _buildImagePreview() {
    if (_pickedImage != null) {
      return kIsWeb
          ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
          : Image.file(File(_pickedImage!.path), fit: BoxFit.cover);
    } else if (widget.producto?.imagen != null) {
      return Image.network(
        "${widget.api.baseUrl}/${widget.producto!.imagen}",
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) =>
                const Icon(Icons.broken_image, color: Colors.grey, size: 60),
      );
    }
    return const Icon(Icons.image, color: Colors.grey, size: 80);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final precio = double.tryParse(_precioCtrl.text) ?? 0.0;
    final idCategoria = catSel?.id;

    try {
      if (widget.producto == null) {
        await widget.api.addProduct(
          nombre: nombre,
          descripcion: desc,
          precio: precio,
          idCategoria: idCategoria!,
          imagen: _pickedImage,
        );
      } else {
        await widget.api.updateProduct(
          id: widget.producto!.id,
          nombre: nombre,
          descripcion: desc,
          precio: precio,
          idCategoria: idCategoria!,
          imagen: _pickedImage,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.producto != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          isEditing ? "⚡ Editar Producto" : "🌙 Nuevo Producto",
          style: const TextStyle(
            color: Colors.purpleAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.purpleAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1E2C), Color(0xFF121212)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(child: _buildImagePreview()),
                      Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.purpleAccent.withOpacity(0.7),
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _buildDarkField(
                controller: _nombreCtrl,
                label: "Nombre del producto",
                icon: Icons.shopping_bag,
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? "El nombre es obligatorio"
                            : null,
              ),
              const SizedBox(height: 20),
              _buildDarkField(
                controller: _descCtrl,
                label: "Descripción",
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildDarkField(
                controller: _precioCtrl,
                label: "Precio",
                icon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? "El precio es obligatorio"
                            : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<Category>(
                value:
                    categorias.any((c) => c.id == catSel?.id) ? catSel : null,
                items:
                    categorias
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              "🏷️ ${c.nombre}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (c) => setState(() => catSel = c),
                decoration: InputDecoration(
                  labelText: "Categoría",
                  labelStyle: const TextStyle(color: Colors.purpleAccent),
                  filled: true,
                  fillColor: const Color(0xFF1E1E2C),
                  prefixIcon: const Icon(Icons.category, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                validator: (v) => v == null ? "Selecciona una categoría" : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    isEditing ? "Actualizar" : "Guardar",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    shadowColor: Colors.purpleAccent,
                    elevation: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDarkField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.purpleAccent),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1E1E2C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
