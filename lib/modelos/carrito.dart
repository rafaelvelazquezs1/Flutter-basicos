import 'articulo_carrito.dart';
import 'producto.dart';

// Agrupa las líneas de compra de una sola persona autenticada.
class Carrito {
  final int usuarioId;
  int? idApi;
  final List<ArticuloCarrito> _articulos;

  Carrito({
    required this.usuarioId,
    int? idApi,
    List<ArticuloCarrito> articulos = const [],
  }) : idApi = idApi,
       _articulos = List<ArticuloCarrito>.from(articulos);

  // La vista puede leer la lista, pero no reemplazarla directamente.
  List<ArticuloCarrito> get articulos => List.unmodifiable(_articulos);
  bool get estaVacio => _articulos.isEmpty;
  double get total => _articulos.fold(0, (suma, item) => suma + item.subtotal);
  String get totalFormateado => '\$${total.toStringAsFixed(2)} MXN';

  // Si el CD ya existe, aumenta la cantidad en lugar de duplicar la línea.
  void agregarProducto(Producto producto, int cantidad) {
    if (cantidad <= 0) return;
    final indice = _articulos.indexWhere(
      (articulo) => articulo.producto.id == producto.id,
    );
    if (indice >= 0) {
      _articulos[indice].sumar(cantidad);
    } else {
      _articulos.add(ArticuloCarrito(producto: producto, cantidad: cantidad));
    }
  }

  void incrementar(int productoId) {
    final articulo = _buscar(productoId);
    articulo?.sumar(1);
  }

  // Devuelve true si al bajar la cantidad se eliminó el artículo.
  bool decrementar(int productoId) {
    final articulo = _buscar(productoId);
    if (articulo == null) return false;
    if (articulo.cantidad == 1) return eliminarProducto(productoId);
    articulo.actualizarCantidad(articulo.cantidad - 1);
    return false;
  }

  bool eliminarProducto(int productoId) {
    final cantidadAntes = _articulos.length;
    _articulos.removeWhere((articulo) => articulo.producto.id == productoId);
    return _articulos.length != cantidadAntes;
  }

  ArticuloCarrito? _buscar(int productoId) {
    for (final articulo in _articulos) {
      if (articulo.producto.id == productoId) return articulo;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'apiId': idApi,
    'userId': usuarioId,
    'items': _articulos.map((articulo) => articulo.toJson()).toList(),
  };

  factory Carrito.desdeJson(
    Map<String, dynamic> json, {
    required int usuarioId,
  }) {
    final datos = json['items'] as List<dynamic>? ?? const [];
    return Carrito(
      usuarioId: usuarioId,
      idApi: (json['apiId'] as num?)?.toInt(),
      articulos: datos
          .whereType<Map>()
          .map(
            (item) =>
                ArticuloCarrito.desdeJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }
}
