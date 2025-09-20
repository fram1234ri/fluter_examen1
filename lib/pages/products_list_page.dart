import 'package:flutter/material.dart';
import '../api/api_services.dart';
import '../models/product.dart';
import '../pages/products_form_page.dart';

/// Pantalla principal con estilo Anime Dark
class ProductListScreen extends StatefulWidget {
  final ApiService api;
  const ProductListScreen({super.key, required this.api});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> futureProducts;
  String search = "";

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      futureProducts = widget.api.getProducts(search: search);
    });
  }

  void _showProductDetail(Product product) {
    final imgUrl =
        product.imagen != null
            ? "${widget.api.baseUrl}/${product.imagen}"
            : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1E2C), Color(0xFF121212)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                if (imgUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imgUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.pinkAccent],
                      ),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  product.nombre,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  product.descripcion,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ProductFormScreen(
                                    api: widget.api,
                                    producto: product,
                                  ),
                            ),
                          );
                          if (result == true) _load();
                        },
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          "Editar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          await widget.api.deleteProduct(product.id);
                          Navigator.pop(context);
                          _load();
                        },
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          "Eliminar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text("🌀 Productos Anime Dark"),
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.purpleAccent,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "🔍 Buscar...",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.purpleAccent),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
              onSubmitted: (val) {
                search = val;
                _load();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: futureProducts,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.purpleAccent,
                    ),
                  );
                }
                if (snap.hasError) {
                  return const Center(
                    child: Text(
                      "Error cargando productos",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  );
                }
                final productos = snap.data ?? [];
                if (productos.isEmpty) {
                  return const Center(
                    child: Text(
                      "No hay productos",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: productos.length,
                  itemBuilder: (_, i) {
                    final p = productos[i];
                    final imgUrl =
                        p.imagen != null
                            ? "${widget.api.baseUrl}/${p.imagen}"
                            : null;
                    return GestureDetector(
                      onTap: () => _showProductDetail(p),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E1E2C), Color(0xFF121212)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child:
                                  imgUrl != null
                                      ? ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(18),
                                            ),
                                        child: Image.network(
                                          imgUrl,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(18),
                                              ),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Colors.deepPurple,
                                              Colors.pinkAccent,
                                            ],
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.white,
                                          size: 60,
                                        ),
                                      ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text(
                                    p.nombre,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "\$${p.precio.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.purpleAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductFormScreen(api: widget.api),
            ),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
