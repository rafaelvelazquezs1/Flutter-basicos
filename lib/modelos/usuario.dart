import 'administrador.dart';
import 'jefe.dart';
import 'usuario_estandar.dart';

// Clase padre y modelo User del backend. Conserva POO mediante sus clases hijas.
abstract class Usuario {
  int _id;
  String _correo;
  String _usuario;
  String _contrasena;
  String _nombre;
  String _apellido;
  String _ciudad;
  String _calle;
  String _numero;
  String _codigoPostal;
  String _latitud;
  String _longitud;
  String _telefono;

  Usuario({
    required int id,
    required String correo,
    required String usuario,
    required String contrasena,
    required String nombre,
    required String apellido,
    required String ciudad,
    required String calle,
    required String numero,
    required String codigoPostal,
    required String latitud,
    required String longitud,
    required String telefono,
  }) : _id = id,
       _correo = correo,
       _usuario = usuario,
       _contrasena = contrasena,
       _nombre = nombre,
       _apellido = apellido,
       _ciudad = ciudad,
       _calle = calle,
       _numero = numero,
       _codigoPostal = codigoPostal,
       _latitud = latitud,
       _longitud = longitud,
       _telefono = telefono;

  int get id => _id;
  String get correo => _correo.trim().toLowerCase();
  String get usuario => _usuario.trim();
  // La contraseña solo se usa para validar el login local; nunca se muestra en UI.
  String get contrasena => _contrasena;
  String get nombreCompleto => '$_nombre $_apellido'.trim();
  String get telefono => _telefono.trim();
  String get direccion => '$_calle #$_numero, $_ciudad'.trim();
  String get codigoPostal => _codigoPostal.trim();
  String get latitud => _latitud;
  String get longitud => _longitud;

  set correo(String valor) {
    if (valor.contains('@')) _correo = valor.trim();
  }

  set telefono(String valor) {
    if (valor.trim().isNotEmpty) _telefono = valor.trim();
  }

  String obtenerRol();
  String obtenerInsignia();

  // Parsea la estructura User: name, address y geolocation son objetos anidados.
  factory Usuario.desdeJson(Map<String, dynamic> json) {
    final nombre = json['name'] as Map<String, dynamic>? ?? {};
    final direccion = json['address'] as Map<String, dynamic>? ?? {};
    final geolocalizacion =
        direccion['geolocation'] as Map<String, dynamic>? ?? {};
    final datos = (
      id: (json['id'] as num? ?? 0).toInt(),
      correo: json['email'] as String? ?? '',
      usuario: json['username'] as String? ?? '',
      contrasena: json['password'] as String? ?? '',
      nombre: nombre['firstname'] as String? ?? '',
      apellido: nombre['lastname'] as String? ?? '',
      ciudad: direccion['city'] as String? ?? '',
      calle: direccion['street'] as String? ?? '',
      numero: direccion['number']?.toString() ?? '',
      codigoPostal: direccion['zipcode'] as String? ?? '',
      latitud: geolocalizacion['lat']?.toString() ?? '',
      longitud: geolocalizacion['long']?.toString() ?? '',
      telefono: json['phone'] as String? ?? '',
    );

    // Regla académica de roles: se conservan las clases hijas existentes.
    if (datos.id == 1 || datos.id == 2) return Administrador.desdeDatos(datos);
    if (datos.id == 3) return Jefe.desdeDatos(datos);
    return UsuarioEstandar.desdeDatos(datos);
  }

  // Genera el JSON con la forma exacta requerida por /api/users.
  Map<String, dynamic> toJson() => {
    'id': _id,
    'email': _correo,
    'username': _usuario,
    'password': _contrasena,
    'name': {'firstname': _nombre, 'lastname': _apellido},
    'address': {
      'city': _ciudad,
      'street': _calle,
      'number': _numero,
      'zipcode': _codigoPostal,
      'geolocation': {'lat': _latitud, 'long': _longitud},
    },
    'phone': _telefono,
  };
}
