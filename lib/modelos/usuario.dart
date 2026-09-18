import 'administrador.dart';
import 'jefe.dart';
import 'usuario_estandar.dart';

abstract class Usuario {
  // Clase padre usada para aplicar herencia y polimorfismo entre roles.
  int _id;
  String _usuario;
  String _correo;
  String _nombreCompleto;
  String _telefono;
  String _direccion;

  Usuario({
    required int id,
    required String usuario,
    required String correo,
    required String nombreCompleto,
    required String telefono,
    required String direccion,
  }) : _id = id,
       _usuario = usuario,
       _correo = correo,
       _nombreCompleto = nombreCompleto,
       _telefono = telefono,
       _direccion = direccion;

  // Getters públicos
  int get id => _id;
  // Getters con formato sencillo para los textos de la interfaz.
  String get usuario => _usuario.trim();
  String get correo => _correo.trim().toLowerCase();
  String get nombreCompleto => _nombreCompleto.trim();
  String get telefono => _telefono.trim();
  String get direccion => _direccion.trim();

  // Setters con validacion para no guardar valores invalidos.
  set correo(String valor) {
    if (valor.contains('@')) _correo = valor.trim();
  }

  set telefono(String valor) {
    if (valor.trim().isNotEmpty) _telefono = valor.trim();
  }

  // Métodos polimórficos
  String obtenerRol();
  String obtenerInsignia();

  // Factory Constructor para mapear el JSON
  factory Usuario.desdeJson(Map<String, dynamic> json) {
    int idUser = json['id'] ?? 0;

    // Extracción segura del nombre
    var nameJson = json['name'] ?? {};
    String firstname = nameJson['firstname'] ?? '';
    String lastname = nameJson['lastname'] ?? '';
    String nombre = "$firstname $lastname".trim();
    if (nombre.isEmpty) nombre = "Usuario sin nombre";

    String email = json['email'] ?? 'Sin correo';
    String username = json['username'] ?? 'Sin usuario';
    String phone = json['phone'] ?? 'Sin teléfono';

    // Extracción segura de la dirección
    var addressJson = json['address'] ?? {};
    String street = addressJson['street'] ?? '';
    var number = addressJson['number']?.toString() ?? '';
    String city = addressJson['city'] ?? '';

    String fullAddress = "$street #$number, $city".trim();
    if (fullAddress == "#," || fullAddress.isEmpty) {
      fullAddress = "Dirección no disponible";
    }

    // Instanciación polimórfica según el ID
    if (idUser == 1 || idUser == 2) {
      return Administrador(
        id: idUser,
        usuario: username,
        correo: email,
        nombreCompleto: nombre,
        telefono: phone,
        direccion: fullAddress,
      );
    } else if (idUser == 3) {
      return Jefe(
        id: idUser,
        usuario: username,
        correo: email,
        nombreCompleto: nombre,
        telefono: phone,
        direccion: fullAddress,
      );
    } else {
      return UsuarioEstandar(
        id: idUser,
        usuario: username,
        correo: email,
        nombreCompleto: nombre,
        telefono: phone,
        direccion: fullAddress,
      );
    }
  }
}
