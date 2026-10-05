import 'package:flutter/foundation.dart';
import 'package:flutter_basicos/conexion/api.dart';
import 'package:flutter_basicos/modelos/usuario.dart';
import 'package:flutter_basicos/servicios/sesion_service.dart';

// Controlador: valida y procesa el login; no contiene widgets ni navegacion.
class LoginController extends ChangeNotifier {
  bool cargando = false;

  Future<Usuario> iniciarSesion(String usuario, String contrasena) async {
    if (usuario.trim().isEmpty || contrasena.trim().isEmpty) {
      throw Exception('Por favor completa todos los campos.');
    }
    cargando = true;
    notifyListeners();
    try {
      final usuarioLogueado = await ApiService.loginYObtenerUsuario(
        usuario.trim(),
        contrasena.trim(),
      );
      await SesionService.guardarSesion(
        token: ApiService.ultimoToken ?? '',
        rol: _normalizarRol(usuarioLogueado),
        usuarioId: usuarioLogueado.id,
      );
      return usuarioLogueado;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // La API no conoce estos tres roles de la tarea, por eso se normalizan aqui.
  String _normalizarRol(Usuario usuario) {
    final rol = usuario.obtenerRol();
    return rol == 'Administrador' || rol == 'Auditor' ? rol : 'Cliente';
  }
}
