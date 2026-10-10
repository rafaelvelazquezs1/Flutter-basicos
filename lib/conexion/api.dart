import 'dart:convert';

import 'package:flutter_basicos/configuracion/api_config.dart';
import 'package:http/http.dart' as http;

import '../modelos/usuario.dart';

// Servicio de usuarios para el backend Express: GET /api/users y /api/users/{id}.
class ApiService {
  // La sesión actual es local porque el contrato proporcionado no incluye /login.
  static String? ultimoToken;

  static Future<Usuario> loginYObtenerUsuario(
    String username,
    String password,
  ) async {
    final respuesta = await http.get(ApiConfig.uri('/api/users'));
    _validarRespuesta(respuesta, 'No fue posible obtener los usuarios.');

    final usuarios = _listaDeRespuesta(respuesta.body);
    final datosUsuario = usuarios
        .where((usuario) => usuario['username'] == username)
        .firstOrNull;

    if (datosUsuario == null || datosUsuario['password'] != password) {
      throw Exception('Usuario o contraseña incorrectos.');
    }

    final usuario = Usuario.desdeJson(datosUsuario);
    // Se usa como marca de sesión hasta que el backend agregue JWT/autenticación.
    ultimoToken = 'sesion-local-${usuario.id}';
    return usuario;
  }

  static Future<Usuario> obtenerUsuarioPorId(int id) async {
    final respuesta = await http.get(ApiConfig.uri('/api/users/$id'));
    _validarRespuesta(respuesta, 'No fue posible obtener el usuario.');
    return Usuario.desdeJson(_objetoDeRespuesta(respuesta.body));
  }

  static List<Map<String, dynamic>> _listaDeRespuesta(String cuerpo) {
    final decodificado = jsonDecode(cuerpo);
    final lista = decodificado is List
        ? decodificado
        : decodificado['users'] as List<dynamic>? ?? [];
    return lista.map((dato) => Map<String, dynamic>.from(dato as Map)).toList();
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
