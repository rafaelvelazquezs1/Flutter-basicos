import 'package:flutter/foundation.dart';
import 'package:flutter_basicos/modelos/producto.dart';
import 'package:flutter_basicos/servicios/api_productos.dart';
import 'package:flutter_basicos/servicios/sesion_service.dart';

// Controlador del detalle: concentra permisos y solicitudes protegidas.
class DetalleProductoController extends ChangeNotifier {
  Producto? producto;
  bool cargando = true;
  bool esAdministrador = false;
  String? rol;

  // Solamente Cliente puede añadir CDs; Auditor conserva su vista de lectura.
  bool get puedeUsarCarrito => rol == 'Cliente';

  Future<void> cargar(int productoId) async {
    try {
      final datos = await Future.wait<dynamic>([
        ApiProductos.obtenerProducto(productoId),
        SesionService.obtenerRol(),
      ]);
      producto = datos[0] as Producto;
      rol = datos[1] as String?;
      esAdministrador = rol == 'Administrador';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // Esta validacion bloquea PUT y DELETE aunque alguien fuerce la navegacion.
  Future<void> editar(Producto actualizado) async {
    _comprobarPermiso();
    await ApiProductos.editarProducto(actualizado);
    producto = actualizado; // Fake Store simula la respuesta; se actualiza la vista local.
    notifyListeners();
  }

  Future<void> eliminar() async {
    _comprobarPermiso();
    await ApiProductos.eliminarProducto(producto!.id);
  }

  void _comprobarPermiso() {
    if (!esAdministrador)
      throw Exception('No tienes permisos para realizar esta acción.');
  }
}
