import 'dart:convert';

import 'package:http/http.dart' as http;

import '../modelos/usuario.dart';

class ApiService {
  static const String _baseUrl = 'https://fakestoreapi.com';
  // Conserva el token recibido hasta que la pantalla de login lo guarde localmente.
  static String? ultimoToken;

  static Future<Usuario> loginYObtenerUsuario(
    String username,
    String password,
  ) async {
    final urlLogin = Uri.parse('$_baseUrl/auth/login');

    final respuestaLogin = await http.post(
      urlLogin,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    print('Código de estado Login: ${respuestaLogin.statusCode}');
    print('Respuesta Login: ${respuestaLogin.body}');

    // Aceptamos tanto 200 como 201 como respuestas exitosas
    if (respuestaLogin.statusCode == 200 || respuestaLogin.statusCode == 201) {
      ultimoToken =
          (jsonDecode(respuestaLogin.body) as Map<String, dynamic>)['token']
              as String?;
      final urlUsuarios = Uri.parse('$_baseUrl/users');
      final respuestaUsuarios = await http.get(urlUsuarios);

      if (respuestaUsuarios.statusCode == 200) {
        List<dynamic> usuarios = jsonDecode(respuestaUsuarios.body);

        final datosUsuario = usuarios.firstWhere(
          (u) => u['username'] == username,
          orElse: () => null,
        );

        if (datosUsuario != null) {
          return Usuario.desdeJson(datosUsuario);
        } else {
          throw Exception('Usuario no encontrado en la lista de la API.');
        }
      } else {
        throw Exception('Error al obtener el listado de usuarios.');
      }
    } else {
      throw Exception('Usuario o contraseña incorrectos.');
    }
  }
}
