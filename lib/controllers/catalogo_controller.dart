import 'package:flutter/foundation.dart';
import 'package:flutter_basicos/modelos/producto.dart';
import 'package:flutter_basicos/servicios/api_productos.dart';
import 'package:flutter_basicos/servicios/sesion_service.dart';

// Controlador del catalogo: conserva su estado fuera de la vista.
class CatalogoController extends ChangeNotifier {
  List<String> categorias = [];
  List<Producto> productos = [];
  String? categoriaActiva;
  String? error;
  bool cargando = false;
  bool esAdministrador = false;

  Future<void> iniciar() async {
    esAdministrador = await SesionService.obtenerRol() == 'Administrador';
    await cargarCatalogo();
  }

  Future<void> cargarCatalogo({String? categoria}) async {
    cargando = true;
    error = null;
    productos = []; // Evita mostrar resultados de la categoria anterior.
    categoriaActiva = categoria;
    notifyListeners();
    try {
      final resultados = await Future.wait<dynamic>([
        ApiProductos.obtenerProductos(categoria: categoria),
        if (categorias.isEmpty) ApiProductos.obtenerCategorias(),
      ]);
      productos = resultados.first as List<Producto>;
      if (categorias.isEmpty && resultados.length > 1)
        categorias = resultados[1] as List<String>;
    } catch (_) {
      error = 'No se pudo cargar el catálogo. Revisa tu conexión.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}
