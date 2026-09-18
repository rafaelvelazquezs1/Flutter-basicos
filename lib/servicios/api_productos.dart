import 'dart:convert';

import 'package:flutter_basicos/modelos/producto.dart';
import 'package:http/http.dart' as http;

// Servicio dedicado a las peticiones de productos de Fake Store API.
class ApiProductos {
  static const String _baseUrl = 'https://fakestoreapi.com';

  // Obtiene todo el catálogo o únicamente una categoría.
  static Future<List<Producto>> obtenerProductos({String? categoria}) async {
    final ruta = categoria == null
        ? '/products'
        : '/products/category/${Uri.encodeComponent(categoria)}';
    final respuesta = await http.get(Uri.parse('$_baseUrl$ruta'));

    if (respuesta.statusCode != 200) {
      throw Exception('No fue posible obtener los productos.');
    }

    final datos = jsonDecode(respuesta.body) as List<dynamic>;
    return datos
        .map((producto) => Producto.desdeJson(producto as Map<String, dynamic>))
        .toList();
  }

  // Obtiene las categorías para construir los filtros interactivos.
  static Future<List<String>> obtenerCategorias() async {
    final respuesta = await http.get(
      Uri.parse('$_baseUrl/products/categories'),
    );
    if (respuesta.statusCode != 200) {
      throw Exception('No fue posible obtener las categorías.');
    }
    return (jsonDecode(respuesta.body) as List<dynamic>).cast<String>();
  }

  // Consulta un solo producto para que el detalle siempre tenga datos actuales.
  static Future<Producto> obtenerProducto(int id) async {
    final respuesta = await http.get(Uri.parse('$_baseUrl/products/$id'));
    if (respuesta.statusCode != 200) {
      throw Exception('Producto no disponible.');
    }
    return Producto.desdeJson(
      jsonDecode(respuesta.body) as Map<String, dynamic>,
    );
  }

  // Actualiza el título en la API de práctica y devuelve el producto resultante.
  static Future<void> editarTitulo(
    Producto producto,
    String nuevoTitulo,
  ) async {
    final respuesta = await http.put(
      Uri.parse('$_baseUrl/products/${producto.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': nuevoTitulo}),
    );
    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw Exception('No fue posible editar el producto.');
    }
  }

  // El endpoint de Fake Store API simula la eliminación del artículo.
  static Future<void> eliminarProducto(int id) async {
    final respuesta = await http.delete(Uri.parse('$_baseUrl/products/$id'));
    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw Exception('No fue posible eliminar el producto.');
    }
  }
}
