import 'usuario.dart';

class UsuarioEstandar extends Usuario {
  UsuarioEstandar({
    required super.id,
    required super.usuario,
    required super.correo,
    required super.nombreCompleto,
    required super.telefono,
    required super.direccion,
  });

  @override
  String obtenerRol() => "Usuario Estándar";

  @override
  String obtenerInsignia() => "👤";
}
