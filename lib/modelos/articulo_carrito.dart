import 'producto.dart';

// Representa una línea del carrito: un CD y cuántas copias desea el cliente.
class ArticuloCarrito {
  final Producto producto;
  int _cantidad;

  ArticuloCarrito({required this.producto, required int cantidad})
    : _cantidad = cantidad > 0 ? cantidad : 1;

  int get cantidad => _cantidad;

  // El subtotal se calcula localmente para que cambie de inmediato en la vista.
  double get subtotal => producto.precio * _cantidad;

  void sumar(int cantidad) {
    if (cantidad > 0) _cantidad += cantidad;
  }

  void actualizarCantidad(int cantidad) {
    if (cantidad > 0) _cantidad = cantidad;
  }

  Map<String, dynamic> toJson() => {
    'product': producto.toJson(),
    'quantity': _cantidad,
  };

  // Recupera la línea cuando el carrito vuelve a cargarse del dispositivo.
  factory ArticuloCarrito.desdeJson(Map<String, dynamic> json) {
    final productoJson = Map<String, dynamic>.from(
      json['product'] as Map<String, dynamic>? ?? {},
    );
    return ArticuloCarrito(
      producto: Producto.desdeJson(productoJson),
      cantidad: (json['quantity'] as num? ?? 1).toInt(),
    );
  }
}
