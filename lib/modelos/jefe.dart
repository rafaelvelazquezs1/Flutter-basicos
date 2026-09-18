import 'usuario.dart';

class Jefe extends Usuario {
  Jefe({
    required super.id,
    required super.usuario,
    required super.correo,
    required super.nombreCompleto,
    required super.telefono,
    required super.direccion,
  });

  @override
  String obtenerRol() => "Auditor";

  @override
  String obtenerInsignia() => "⭐";
}
