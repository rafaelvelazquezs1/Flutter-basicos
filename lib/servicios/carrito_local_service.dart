import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/carrito.dart';

// Guarda el carrito por usuario en el mismo dispositivo mientras la sesión viva.
class CarritoLocalService {
  String _llave(int usuarioId) => 'carrito_$usuarioId';

  Future<Carrito> cargar(int usuarioId) async {
    final preferencias = await SharedPreferences.getInstance();
    final texto = preferencias.getString(_llave(usuarioId));
    if (texto == null) return Carrito(usuarioId: usuarioId);

    try {
      final datos = Map<String, dynamic>.from(jsonDecode(texto) as Map);
      return Carrito.desdeJson(datos, usuarioId: usuarioId);
    } catch (_) {
      // Si existiera información dañada, se elimina para poder iniciar limpio.
      await preferencias.remove(_llave(usuarioId));
      return Carrito(usuarioId: usuarioId);
    }
  }

  Future<void> guardar(Carrito carrito) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(
      _llave(carrito.usuarioId),
      jsonEncode(carrito.toJson()),
    );
  }

  Future<void> limpiar(int usuarioId) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove(_llave(usuarioId));
  }
}
