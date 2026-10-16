import 'package:flutter/foundation.dart';
import 'package:flutter_basicos/configuracion/api_config.dart';
import 'package:flutter_basicos/modelos/producto.dart';
import 'package:flutter_basicos/servicios/api_productos.dart';
import 'package:flutter_basicos/servicios/sesion_service.dart';

// Controlador del catalogo: conserva su estado fuera de la vista.
class CatalogoController extends ChangeNotifier {
  List<String> categorias = ApiConfig.categorias;
  List<Producto> productos = [];
  String categoriaActiva = ApiConfig.todas;
  String? error;
  bool cargando = false;
  bool esAdministrador = false;
  String? rol;

  // Auditor no ve controles de carrito; el caso de uso corresponde a Cliente.
  bool get puedeUsarCarrito => rol == 'Cliente';

  Future<void> iniciar() async {
    rol = await SesionService.obtenerRol();
    esAdministrador = rol == 'Administrador';
    await cargarCatalogo(categoria: ApiConfig.todas);
  }

  Future<void> cargarCatalogo({String? categoria}) async {
    cargando = true;
    error = null;
    productos = []; // Evita mostrar resultados de la categoria anterior.
    categoriaActiva = categoria ?? ApiConfig.todas;
    notifyListeners();
    try {
      productos = await ApiProductos.obtenerProductos(
        categoria: categoriaActiva,
      );
      categorias = await ApiProductos.obtenerCategorias();
    } catch (_) {
      error = 'No se pudo cargar el catálogo. Revisa tu conexión.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}
