import 'package:flutter/foundation.dart';
import 'package:flutter_basicos/modelos/carrito.dart';
import 'package:flutter_basicos/modelos/producto.dart';
import 'package:flutter_basicos/servicios/api_carritos.dart';
import 'package:flutter_basicos/servicios/carrito_local_service.dart';
import 'package:flutter_basicos/servicios/sesion_service.dart';

// Mantiene las reglas del carrito fuera de las pantallas de Flutter.
class CarritoController extends ChangeNotifier {
  CarritoController({
    CarritoLocalService? servicioLocal,
    ApiCarritos? apiCarritos,
  }) : _servicioLocal = servicioLocal ?? CarritoLocalService(),
       _apiCarritos = apiCarritos ?? ApiCarritos();

  final CarritoLocalService _servicioLocal;
  final ApiCarritos _apiCarritos;

  Carrito? _carrito;
  String? _rol;
  bool cargando = true;
  bool sincronizando = false;
  String? avisoSincronizacion;

  Carrito get carrito => _carrito ?? Carrito(usuarioId: 0);
  bool get estaVacio => carrito.estaVacio;
  bool get puedeUsarCarrito => _rol == 'Cliente';

  Future<void> iniciar() async {
    cargando = true;
    notifyListeners();
    try {
      final datos = await Future.wait<dynamic>([
        SesionService.obtenerUsuarioId(),
        SesionService.obtenerRol(),
      ]);
      final usuarioId = datos[0] as int?;
      _rol = datos[1] as String?;
      if (usuarioId == null) {
        throw Exception('No existe una sesión activa para el carrito.');
      }
      _carrito = await _servicioLocal.cargar(usuarioId);
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  // Agregar el mismo CD vuelve a sumar unidades y nunca crea una línea duplicada.
  Future<bool> agregar(Producto producto, int cantidad) async {
    _comprobarAcceso();
    if (cantidad <= 0) throw Exception('Selecciona una cantidad mayor a cero.');
    carrito.agregarProducto(producto, cantidad);
    await _guardarLocalmente();
    return _crearOActualizarEnApi();
  }

  Future<bool> incrementar(int productoId) async {
    _comprobarAcceso();
    carrito.incrementar(productoId);
    await _guardarLocalmente();
    return _crearOActualizarEnApi();
  }

  Future<bool> decrementar(int productoId) async {
    _comprobarAcceso();
    final eliminado = carrito.decrementar(productoId);
    await _guardarLocalmente();
    if (eliminado) return _eliminarEnApi(productoId);
    return _crearOActualizarEnApi();
  }

  Future<bool> eliminar(int productoId) async {
    _comprobarAcceso();
    if (!carrito.eliminarProducto(productoId)) return true;
    await _guardarLocalmente();
    return _eliminarEnApi(productoId);
  }

  Future<void> _guardarLocalmente() async {
    await _servicioLocal.guardar(carrito);
    notifyListeners();
  }

  // La historia exige actualizar primero el estado local. Si Render está dormido
  // o falla la red, el usuario conserva su carrito y recibe un aviso honesto.
  Future<bool> _crearOActualizarEnApi() async {
    sincronizando = true;
    avisoSincronizacion = null;
    notifyListeners();
    try {
      if (carrito.idApi == null) {
        carrito.idApi = await _apiCarritos.crear(carrito);
        await _guardarLocalmente();
      } else {
        await _apiCarritos.actualizar(carrito);
      }
      return true;
    } catch (_) {
      avisoSincronizacion = 'El carrito se guardó en este dispositivo, pero no se pudo sincronizar con el servidor.';
      return false;
    } finally {
      sincronizando = false;
      notifyListeners();
    }
  }

  Future<bool> _eliminarEnApi(int productoId) async {
    sincronizando = true;
    avisoSincronizacion = null;
    notifyListeners();
    try {
      final idCarrito = carrito.idApi;
      if (idCarrito == null) return true;
      if (carrito.estaVacio) {
        await _apiCarritos.eliminarCarrito(idCarrito);
        carrito.idApi = null;
        await _guardarLocalmente();
      } else {
        await _apiCarritos.eliminarArticulo(
          idCarrito: idCarrito,
          idProducto: productoId,
        );
      }
      return true;
    } catch (_) {
      avisoSincronizacion = 'El artículo se eliminó localmente, pero no se pudo sincronizar con el servidor.';
      return false;
    } finally {
      sincronizando = false;
      notifyListeners();
    }
  }

  void _comprobarAcceso() {
    if (!puedeUsarCarrito) {
      throw Exception('El carrito está disponible solamente para Clientes.');
    }
  }
}
