import 'dart:convert';

import 'package:flutter_basicos/modelos/producto.dart';
import 'package:http/http.dart' as http;

// Este servicio es la unica capa que conoce las rutas de Fake Store API.
class ApiProductos {
  static const String _baseUrl = 'https://fakestoreapi.com';

  static Future<List<Producto>> obtenerProductos({String? categoria}) async {
    final ruta = categoria == null
        ? '/products'
        : '/products/category/${Uri.encodeComponent(categoria)}';
    final respuesta = await http.get(Uri.parse('$_baseUrl$ruta'));
    _validarRespuesta(respuesta, 'No fue posible obtener los productos.');
    final datos = jsonDecode(respuesta.body) as List<dynamic>;
    return datos
        .map((dato) => Producto.desdeJson(dato as Map<String, dynamic>))
        .toList();
  }

  static Future<List<String>> obtenerCategorias() async {
    final respuesta = await http.get(
      Uri.parse('$_baseUrl/products/categories'),
    );
    _validarRespuesta(respuesta, 'No fue posible obtener las categorías.');
    return (jsonDecode(respuesta.body) as List<dynamic>).cast<String>();
  }

  static Future<Producto> obtenerProducto(int id) async {
    final respuesta = await http.get(Uri.parse('$_baseUrl/products/$id'));
    _validarRespuesta(respuesta, 'Producto no disponible.');
    return Producto.desdeJson(
      jsonDecode(respuesta.body) as Map<String, dynamic>,
    );
  }

  // POST usado por US06. La API devuelve un ID, aunque no guarda el producto realmente.
  static Future<Producto> crearProducto(Producto producto) async {
    final respuesta = await http.post(
      Uri.parse('$_baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_productoAJson(producto)),
    );
    _validarRespuesta(respuesta, 'No fue posible crear el producto.');
    return Producto.desdeJson(
      jsonDecode(respuesta.body) as Map<String, dynamic>,
    );
  }

  // PUT usado por US07. Recibe todos los campos modificables del formulario.
  static Future<Producto> editarProducto(Producto producto) async {
    final respuesta = await http.put(
      Uri.parse('$_baseUrl/products/${producto.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_productoAJson(producto)),
    );
    _validarRespuesta(respuesta, 'No fue posible actualizar el producto.');
    return Producto.desdeJson(
      jsonDecode(respuesta.body) as Map<String, dynamic>,
    );
  }

  // DELETE usado por US08. El controlador verifica el permiso antes de llamar este metodo.
  static Future<void> eliminarProducto(int id) async {
    final respuesta = await http.delete(Uri.parse('$_baseUrl/products/$id'));
    _validarRespuesta(respuesta, 'No fue posible eliminar el producto.');
  }

  static Map<String, dynamic> _productoAJson(Producto producto) => {
    'title': producto.titulo,
    'price': producto.precio,
    'description': producto.descripcion,
    'image': producto.imagen,
    'category': producto.categoria,
  };

  static void _validarRespuesta(http.Response respuesta, String mensaje) {
    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300)
      throw Exception(mensaje);
  }
}
