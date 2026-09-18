import 'package:shared_preferences/shared_preferences.dart';

// Centraliza los datos de sesión guardados en el dispositivo.
class SesionService {
  static const _token = 'token';
  static const _rol = 'rol';
  static const _usuarioId = 'usuario_id';

  // Guarda solo los datos que las pantallas necesitan para validar la sesión.
  static Future<void> guardarSesion({
    required String token,
    required String rol,
    required int usuarioId,
  }) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(_token, token);
    await preferencias.setString(_rol, rol);
    await preferencias.setInt(_usuarioId, usuarioId);
  }

  // El detalle consulta el rol local; no confía en la API para los permisos.
  static Future<String?> obtenerRol() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString(_rol);
  }

  // Borra token, rol, identificador y cualquier dato local de la sesión anterior.
  static Future<void> cerrarSesion() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.clear();
  }
}
