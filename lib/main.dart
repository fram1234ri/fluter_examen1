import 'package:flutter/material.dart';
import 'api/api_services.dart';
import 'package:flutter_php_2/pages/products_form_page.dart';
import 'package:flutter_php_2/pages/products_list_page.dart';

/// Punto de entrada de la aplicación
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ⚠️ Ajusta la URL según tu entorno:
    // - "http://10.0.2.2/APIAPPJAPON1" → emulador Android
    // - "http://localhost/APIAPPJAPON1" → Web/Desktop
    final api = ApiService("http://10.0.2.2/APIAPPJAPON1");

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestión de Productos',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      routes: {
        "/": (_) => ProductListScreen(api: api),
        "/form": (_) => ProductFormScreen(api: api),
      },
    );
  }
}
