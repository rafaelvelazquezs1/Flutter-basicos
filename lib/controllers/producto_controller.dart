import 'package:flutter/foundation.dart';
import 'package:flutter_basicos/modelos/producto.dart';
import 'package:flutter_basicos/servicios/api_productos.dart';
import 'package:flutter_basicos/servicios/sesion_service.dart';

// Controlador compartido por los formularios Crear y Editar.
class ProductoController extends ChangeNotifier {
  bool cargando = false;

  // Devuelve un mapa de errores para que la vista marque los campos en rojo.
  Map<String, String> validar({
    required String titulo,
    required String precio,
    required String descripcion,
    required String categoria,
    required String imagen,
  }) {
    final errores = <String, String>{};
    if (titulo.trim().isEmpty) errores['titulo'] = 'El título es obligatorio.';
    if (double.tryParse(precio.trim()) == null ||
        (double.tryParse(precio.trim()) ?? -1) < 0)
      errores['precio'] = 'Escribe un precio numérico válido.';
    if (descripcion.trim().isEmpty)
      errores['descripcion'] = 'La descripción es obligatoria.';
    if (categoria.trim().isEmpty)
      errores['categoria'] = 'La categoría es obligatoria.';
    final url = Uri.tryParse(imagen.trim());
    if (url == null ||
        url.host.isEmpty ||
        !(url.scheme == 'http' || url.scheme == 'https'))
      errores['imagen'] = 'Escribe una URL válida de imagen.';
    return errores;
  }

  Future<Producto> crear(Producto producto) async {
    await _comprobarAdministrador();
    cargando = true;
    notifyListeners();
    try {
      return await ApiProductos.crearProducto(producto);
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> comprobarAcceso() => _comprobarAdministrador();

  Future<void> _comprobarAdministrador() async {
    if (await SesionService.obtenerRol() != 'Administrador')
      throw Exception('Acceso solo permitido para Administrador.');
  }
}
