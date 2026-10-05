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
  // Para estas historias, el usuario estándar representa el rol Cliente.
  String obtenerRol() => "Cliente";

  @override
  String obtenerInsignia() => "👤";
}
