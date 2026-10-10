import 'dart:convert';

import 'package:flutter_basicos/configuracion/api_config.dart';
import 'package:flutter_basicos/modelos/producto.dart';
import 'package:http/http.dart' as http;

// Servicio de productos: solamente consume rutas del backend local Express.
class ApiProductos {
  static Future<List<Producto>> obtenerProductos({String? categoria}) async {
    final respuesta = await http.get(ApiConfig.uri('/api/products'));
    _validarRespuesta(respuesta, 'No fue posible obtener los CDs.');
    final productos = _listaDeProductos(respuesta.body);
    // El contrato no define un endpoint de categoría; se filtra la lista local.
    if (categoria == null || categoria == ApiConfig.todas) return productos;
    return productos
        .where((producto) => producto.categoria == categoria)
        .toList();
  }

  // Las categorías pertenecen al catálogo de Música CDs y son fijas en la app.
  static Future<List<String>> obtenerCategorias() async => ApiConfig.categorias;

  static Future<Producto> obtenerProducto(int id) async {
    final respuesta = await http.get(ApiConfig.uri('/api/products/$id'));
    _validarRespuesta(respuesta, 'CD no disponible.');
    return Producto.desdeJson(_objetoDeProducto(respuesta.body));
  }

  static Future<Producto> crearProducto(Producto producto) async {
    final respuesta = await http.post(
      ApiConfig.uri('/api/products'),
      headers: _cabecerasJson,
      body: jsonEncode(producto.toJson()),
    );
    _validarRespuesta(respuesta, 'No fue posible crear el CD.');
    return Producto.desdeJson(_objetoDeProducto(respuesta.body));
  }

  static Future<Producto> editarProducto(Producto producto) async {
    final respuesta = await http.put(
      ApiConfig.uri('/api/products/${producto.id}'),
      headers: _cabecerasJson,
      body: jsonEncode(producto.toJson()),
    );
    _validarRespuesta(respuesta, 'No fue posible actualizar el CD.');
    return Producto.desdeJson(_objetoDeProducto(respuesta.body));
  }

  static Future<void> eliminarProducto(int id) async {
    final respuesta = await http.delete(ApiConfig.uri('/api/products/$id'));
    _validarRespuesta(respuesta, 'No fue posible eliminar el CD.');
  }

  static const _cabecerasJson = {'Content-Type': 'application/json'};

  // Acepta una lista directa o un backend que responda { products: [...] }.
  static List<Producto> _listaDeProductos(String cuerpo) {
    final decodificado = jsonDecode(cuerpo);
    final lista = decodificado is List
        ? decodificado
        : decodificado['products'] as List<dynamic>? ?? [];
    return lista
        .map(
          (dato) => Producto.desdeJson(Map<String, dynamic>.from(dato as Map)),
        )
        .toList();
  }

  // Acepta un producto directo o la forma { product: {...} }.
  static Map<String, dynamic> _objetoDeProducto(String cuerpo) {
    final decodificado = jsonDecode(cuerpo);
    final objeto = decodificado is Map<String, dynamic>
        ? decodificado
        : decodificado['product'] as Map<String, dynamic>?;
    if (objeto == null) throw Exception('Respuesta de producto inválida.');
    return Map<String, dynamic>.from(objeto);
  }

  static void _validarRespuesta(http.Response respuesta, String mensaje) {
    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300)
      throw Exception(mensaje);
  }
}
