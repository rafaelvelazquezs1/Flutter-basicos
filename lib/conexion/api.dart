import 'dart:convert';

import 'package:flutter_basicos/configuracion/api_config.dart';
import 'package:http/http.dart' as http;

import '../modelos/usuario.dart';

// Servicio de usuarios para el backend Express.
class ApiService {
  // La app conserva una marca local; JWT no forma parte de esta práctica.
  static String? ultimoToken;

  static Future<Usuario> loginYObtenerUsuario(
    String username,
    String password,
  ) async {
    // Las credenciales viajan por HTTPS solo al endpoint de inicio de sesión.
    // Así, la app ya no descarga la lista completa de usuarios ni contraseñas.
    final respuesta = await http.post(
      ApiConfig.uri('/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    _validarRespuesta(respuesta, 'Usuario o contraseña incorrectos.');

    final usuario = Usuario.desdeJson(_objetoDeRespuesta(respuesta.body));
    // Se usa como marca local mientras la práctica no implemente JWT.
    ultimoToken = 'sesion-local-${usuario.id}';
    return usuario;
  }

  static Future<Usuario> obtenerUsuarioPorId(int id) async {
    final respuesta = await http.get(ApiConfig.uri('/api/users/$id'));
    _validarRespuesta(respuesta, 'No fue posible obtener el usuario.');
    return Usuario.desdeJson(_objetoDeRespuesta(respuesta.body));
  }

  static Map<String, dynamic> _objetoDeRespuesta(String cuerpo) {
    final decodificado = jsonDecode(cuerpo);
    final objeto = decodificado is Map<String, dynamic>
        ? decodificado
        : decodificado['user'] as Map<String, dynamic>?;
    if (objeto == null) throw Exception('Respuesta de usuario inválida.');
    return Map<String, dynamic>.from(objeto);
  }

  static void _validarRespuesta(http.Response respuesta, String mensaje) {
    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300)
      throw Exception(mensaje);
  }
}
