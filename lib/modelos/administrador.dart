import 'usuario.dart';

class Administrador extends Usuario {
  Administrador({
    required super.id,
    required super.usuario,
    required super.correo,
    required super.nombreCompleto,
    required super.telefono,
    required super.direccion,
  });

  @override
  String obtenerRol() => "Administrador";

  @override
  String obtenerInsignia() => "👑";
}
