import 'usuario.dart';

class UsuarioEstandar extends Usuario {
  UsuarioEstandar({
    required super.id,
    required super.correo,
    required super.usuario,
    required super.contrasena,
    required super.nombre,
    required super.apellido,
    required super.ciudad,
    required super.calle,
    required super.numero,
    required super.codigoPostal,
    required super.latitud,
    required super.longitud,
    required super.telefono,
  });
  UsuarioEstandar.desdeDatos(dynamic datos)
    : this(
        id: datos.id,
        correo: datos.correo,
        usuario: datos.usuario,
        contrasena: datos.contrasena,
        nombre: datos.nombre,
        apellido: datos.apellido,
        ciudad: datos.ciudad,
        calle: datos.calle,
        numero: datos.numero,
        codigoPostal: datos.codigoPostal,
        latitud: datos.latitud,
        longitud: datos.longitud,
        telefono: datos.telefono,
      );
  @override
  String obtenerRol() => 'Cliente';
  @override
  String obtenerInsignia() => '👤';
}
