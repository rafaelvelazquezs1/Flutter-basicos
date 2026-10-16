import 'dart:convert';

import 'package:flutter_basicos/configuracion/api_config.dart';
import 'package:flutter_basicos/modelos/carrito.dart';
import 'package:http/http.dart' as http;

// Practica las solicitudes de carrito; el carrito local sigue siendo la fuente
// de verdad para cumplir con las historias de usuario. La historia pide la
// ruta /carts; el backend también conserva /api/carts como alternativa.
class ApiCarritos {
  Future<int> crear(Carrito carrito) async {
    final respuesta = await http.post(
      ApiConfig.uri('/carts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_datosParaApi(carrito)),
    );
    _validar(respuesta, 'No fue posible avisar al servidor del carrito.');
    final datos = Map<String, dynamic>.from(jsonDecode(respuesta.body) as Map);
    final id = (datos['id'] as num?)?.toInt();
    if (id == null)
      throw Exception('El servidor no devolvió el id del carrito.');
    return id;
  }

  Future<void> actualizar(Carrito carrito) async {
    final id = carrito.idApi;
    if (id == null) throw Exception('El carrito aún no tiene identificador.');
    final respuesta = await http.put(
      ApiConfig.uri('/carts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_datosParaApi(carrito)),
    );
    _validar(respuesta, 'No fue posible actualizar el carrito en el servidor.');
  }

  Future<void> eliminarArticulo({
    required int idCarrito,
    required int idProducto,
  }) async {
    final respuesta = await http.delete(
      ApiConfig.uri(
        '/carts/$idCarrito',
        queryParameters: {'productId': '$idProducto'},
      ),
    );
    _validar(respuesta, 'No fue posible eliminar el artículo en el servidor.');
  }

  Future<void> eliminarCarrito(int idCarrito) async {
    final respuesta = await http.delete(ApiConfig.uri('/carts/$idCarrito'));
    _validar(respuesta, 'No fue posible eliminar el carrito en el servidor.');
  }

  Map<String, dynamic> _datosParaApi(Carrito carrito) => {
    'userId': carrito.usuarioId,
    'date': DateTime.now().toIso8601String(),
    'products': carrito.articulos
        .map(
          (articulo) => {
            'productId': articulo.producto.id,
            'quantity': articulo.cantidad,
          },
        )
        .toList(),
  };

  void _validar(http.Response respuesta, String mensaje) {
    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw Exception(mensaje);
    }
  }
}
